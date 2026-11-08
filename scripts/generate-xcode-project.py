"""Generate a dependency-free Xcode project with app, unit and UI test targets."""
import hashlib, json
from pathlib import Path

root = Path(__file__).resolve().parents[1] / 'ios'
project = root / 'ClassicalGuide.xcodeproj'
project.mkdir(exist_ok=True)
objects = {}
def uid(key): return hashlib.sha1(key.encode()).hexdigest()[:24].upper()
def q(value): return json.dumps(str(value), ensure_ascii=False)
def add(key, body):
    value = uid(key); objects[value] = '{ ' + body + ' };'; return value
def arr(values): return '(' + ', '.join(values) + ',)' if values else '()'
def settings(values): return '{ ' + ' '.join(f'{key} = {q(value)};' for key,value in values.items()) + ' }'

app_sources = sorted((root/'ClassicalGuide').rglob('*.swift'))
unit_sources = sorted((root/'ClassicalGuideTests').glob('*.swift'))
ui_sources = sorted((root/'ClassicalGuideUITests').glob('*.swift'))
resources = [root/'ClassicalGuide/Resources/catalog.json', root/'ClassicalGuide/Resources/PrivacyInfo.xcprivacy', root/'ClassicalGuide/Assets.xcassets']
groups = []
phases = {}
for name, sources, res in [('ClassicalGuide',app_sources,resources),('ClassicalGuideTests',unit_sources,[]),('ClassicalGuideUITests',ui_sources,[])]:
    refs, source_builds, resource_builds = [], [], []
    for path in sources + res:
        relative = str(path.relative_to(root))
        kind = 'sourcecode.swift' if path.suffix == '.swift' else 'folder.assetcatalog' if path.suffix == '.xcassets' else 'text.json' if path.suffix == '.json' else 'text.xml'
        ref = add('file:'+relative, f'isa = PBXFileReference; lastKnownFileType = {kind}; path = {q(relative)}; sourceTree = SOURCE_ROOT;')
        refs.append(ref)
        build = add('build:'+relative, f'isa = PBXBuildFile; fileRef = {ref};')
        (source_builds if path in sources else resource_builds).append(build)
    groups.append(add('group:'+name, f'isa = PBXGroup; name = {q(name)}; children = {arr(refs)}; sourceTree = "<group>";'))
    source_phase = add('sourcephase:'+name, f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = {arr(source_builds)}; runOnlyForDeploymentPostprocessing = 0;')
    resource_phase = add('resourcephase:'+name, f'isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = {arr(resource_builds)}; runOnlyForDeploymentPostprocessing = 0;')
    framework_phase = add('frameworkphase:'+name, 'isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
    phases[name] = [source_phase,framework_phase,resource_phase]

base = {'IPHONEOS_DEPLOYMENT_TARGET':'17.0','SDKROOT':'iphoneos','SWIFT_VERSION':'5.0','CLANG_ENABLE_MODULES':'YES','CLANG_ENABLE_OBJC_ARC':'YES','GCC_C_LANGUAGE_STANDARD':'gnu17','SWIFT_STRICT_CONCURRENCY':'complete','ENABLE_USER_SCRIPT_SANDBOXING':'YES'}
configs = []
for mode in ['Debug','Release']:
    s = dict(base)
    s['DEVELOPMENT_TEAM'] = 'KW9NTQUH4T'
    s['ONLY_ACTIVE_ARCH'] = 'YES' if mode == 'Debug' else 'NO'
    s.update({'DEBUG_INFORMATION_FORMAT':'dwarf' if mode=='Debug' else 'dwarf-with-dsym','SWIFT_OPTIMIZATION_LEVEL':'-Onone' if mode=='Debug' else '-O','ENABLE_TESTABILITY':'YES' if mode=='Debug' else 'NO','SWIFT_ACTIVE_COMPILATION_CONDITIONS':'DEBUG' if mode=='Debug' else ''})
    configs.append(add('projectconfig:'+mode, f'isa = XCBuildConfiguration; buildSettings = {settings(s)}; name = {mode};'))
project_configs = add('projectconfigs', f'isa = XCConfigurationList; buildConfigurations = {arr(configs)}; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')

products, targets = [], []
for name in phases:
    isapp = name == 'ClassicalGuide'
    product = add('product:'+name, f'isa = PBXFileReference; explicitFileType = {"wrapper.application" if isapp else "wrapper.cfbundle"}; path = {q(name + (".app" if isapp else ".xctest"))}; sourceTree = BUILT_PRODUCTS_DIR;')
    products.append(product)
    configs = []
    for mode in ['Debug','Release']:
        s = {'PRODUCT_NAME':'$(TARGET_NAME)','PRODUCT_BUNDLE_IDENTIFIER':'me.zhuhong.classicalguide' + ('' if isapp else '.'+name),'CODE_SIGN_STYLE':'Automatic','TARGETED_DEVICE_FAMILY':'1,2','GENERATE_INFOPLIST_FILE':'YES','MARKETING_VERSION':'1.0.0','CURRENT_PROJECT_VERSION':'1','SUPPORTED_PLATFORMS':'iphoneos iphonesimulator','SUPPORTS_MACCATALYST':'NO','SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD':'NO','SWIFT_EMIT_LOC_STRINGS':'YES'}
        if isapp:
            s.update({'INFOPLIST_FILE':'ClassicalGuide/Resources/Info.plist','INFOPLIST_KEY_CFBundleDisplayName':'古典指南','INFOPLIST_KEY_LSApplicationCategoryType':'public.app-category.music','ASSETCATALOG_COMPILER_APPICON_NAME':'AppIcon','ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME':'AccentColor','LD_RUNPATH_SEARCH_PATHS':'$(inherited) @executable_path/Frameworks'})
        elif name == 'ClassicalGuideTests':
            s.update({'BUNDLE_LOADER':'$(TEST_HOST)','TEST_HOST':'$(BUILT_PRODUCTS_DIR)/ClassicalGuide.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/ClassicalGuide'})
        else: s['TEST_TARGET_NAME'] = 'ClassicalGuide'
        configs.append(add(name+':config:'+mode, f'isa = XCBuildConfiguration; buildSettings = {settings(s)}; name = {mode};'))
    configlist = add(name+':configs', f'isa = XCConfigurationList; buildConfigurations = {arr(configs)}; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
    deps = []
    if not isapp:
        proxy = add('proxy:'+name, f'isa = PBXContainerItemProxy; containerPortal = {uid("project")}; proxyType = 1; remoteGlobalIDString = {uid("target:ClassicalGuide")}; remoteInfo = ClassicalGuide;')
        deps.append(add('dependency:'+name, f'isa = PBXTargetDependency; target = {uid("target:ClassicalGuide")}; targetProxy = {proxy};'))
    producttype = 'application' if isapp else 'bundle.unit-test' if name=='ClassicalGuideTests' else 'bundle.ui-testing'
    targets.append(add('target:'+name, f'isa = PBXNativeTarget; buildConfigurationList = {configlist}; buildPhases = {arr(phases[name])}; buildRules = (); dependencies = {arr(deps)}; name = {q(name)}; productName = {q(name)}; productReference = {product}; productType = {q("com.apple.product-type."+producttype)};'))
productgroup = add('products', f'isa = PBXGroup; name = Products; children = {arr(products)}; sourceTree = "<group>";')
main = add('main', f'isa = PBXGroup; children = {arr(groups+[productgroup])}; sourceTree = "<group>";')
add('project', f'isa = PBXProject; attributes = {{ BuildIndependentTargetsInParallel = YES; LastUpgradeCheck = 2700; }}; buildConfigurationList = {project_configs}; compatibilityVersion = "Xcode 14.0"; developmentRegion = "zh-Hans"; hasScannedForEncodings = 0; knownRegions = ("zh-Hans", en, Base); mainGroup = {main}; productRefGroup = {productgroup}; projectDirPath = ""; projectRoot = ""; targets = {arr(targets)};')
project.joinpath('project.pbxproj').write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+ '\n'.join(f'{key} = {value}' for key,value in objects.items()) +f'\n}}; rootObject = {uid("project")}; }}\n')
def buildref(name): return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid("target:"+name)}" BuildableName="{name}{".app" if name=="ClassicalGuide" else ".xctest"}" BlueprintName="{name}" ReferencedContainer="container:ClassicalGuide.xcodeproj"/>'
scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2700" version="1.3">
 <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{buildref('ClassicalGuide')}</BuildActionEntry></BuildActionEntries></BuildAction>
 <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{buildref('ClassicalGuideTests')}</TestableReference><TestableReference skipped="NO">{buildref('ClassicalGuideUITests')}</TestableReference></Testables></TestAction>
 <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{buildref('ClassicalGuide')}</BuildableProductRunnable></LaunchAction>
 <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{buildref('ClassicalGuide')}</BuildableProductRunnable></ProfileAction>
 <AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>'''
schemes = project/'xcshareddata/xcschemes'
schemes.mkdir(parents=True,exist_ok=True)
(schemes/'ClassicalGuide.xcscheme').write_text(scheme)
print(f'Generated {project} ({len(app_sources)} app source files)')
