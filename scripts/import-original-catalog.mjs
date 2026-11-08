// One-time migration of the audited static data declarations; never evaluates page UI code.
import fs from 'node:fs';
import vm from 'node:vm';
const source = fs.readFileSync(process.argv[2] || 'index.html', 'utf8');
const start = source.indexOf('var COMPOSERS =');
const end = source.indexOf('var appleSvg =', start);
if (start < 0 || end < 0) throw new Error('Original catalog declarations not found');
const context = Object.create(null);
vm.runInNewContext(source.slice(start, end), context, { timeout: 1000, contextCodeGeneration: {strings: false, wasm: false} });
const { COMPOSERS, PERFORMERS, STAGES } = context;
const ids = ['vivaldi-spring','pachelbel-canon','beethoven-fur-elise','dvorak-new-world-largo','saint-saens-swan','grieg-morning','mozart-symphony-40','beethoven-symphony-5','tchaikovsky-piano-concerto-1','mendelssohn-violin-concerto','schubert-unfinished','rachmaninoff-piano-concerto-2','bach-air','bach-cello-prelude','debussy-clair-de-lune','debussy-faun','smetana-vltava','holst-jupiter','beethoven-symphony-9','mahler-resurrection','tchaikovsky-pathetique','brahms-symphony-4','shostakovich-symphony-5','wagner-valkyries','beethoven-moonlight','chopin-nocturne-9-2','schubert-trout','beethoven-kreutzer'];
const genres = ['协奏曲','室内乐','钢琴独奏','交响曲','室内乐','管弦乐','交响曲','交响曲','协奏曲','协奏曲','交响曲','协奏曲','管弦乐','独奏','钢琴独奏','管弦乐','管弦乐','管弦乐','交响曲','交响曲','交响曲','交响曲','交响曲','歌剧选段','钢琴独奏','钢琴独奏','室内乐','室内乐'];
const eras = {vivaldi:'巴洛克',pachelbel:'巴洛克',bach:'巴洛克',beethoven:'古典主义',mozart:'古典主义',debussy:'印象主义',holst:'20 世纪',shostakovich:'20 世纪'};
let i = 0;
const works = STAGES.flatMap(stage => stage.tracks.map(t => ({id:ids[i], legacyID:`t${++i}`, stageID:stage.id, title:t.cn, subtitle:t.en, composerID:t.composer, minutes:parseInt(t.duration,10), summary:t.tip, searchTerm:t.search, recommendation:t.recommend, performerNote:PERFORMERS[t.recommend] || '', genre:genres[i-1], listeningGuide:[]})));
const composers = Object.entries(COMPOSERS).map(([id,c]) => ({id, name:STAGES.flatMap(s=>s.tracks).find(t=>t.composer === id).composerLabel.split(' ')[0], latinName:STAGES.flatMap(s=>s.tracks).find(t=>t.composer === id).composerLabel.split(' ').slice(1).join(' '), initial:c.initial, colorHex:c.color, biography:c.bio, era:eras[id] || '浪漫主义'}));
const catalog = {schemaVersion:1, stages:STAGES.map(s=>({id:s.id,title:s.title,subtitle:s.desc})), composers, works};
if (works.length !== 28 || composers.length !== 20 || new Set(ids).size !== 28) throw new Error('Unexpected source structure');
fs.writeFileSync('ios/ClassicalGuide/Resources/catalog.json', JSON.stringify(catalog,null,2)+'\n');
