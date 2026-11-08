import SwiftUI

enum GuideTheme {
    static let accent = Color("AccentColor")
    static let paper = Color("Paper")
    static let card = Color("Card")
}

struct ComposerMark: View {
    let composer: Composer?
    var size: CGFloat = 56
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.2).fill(GuideTheme.accent.opacity(0.09))
            ForEach(0..<5) { index in
                Rectangle().fill(GuideTheme.accent.opacity(0.13)).frame(height: 0.5)
                    .offset(y: CGFloat(index - 2) * size * 0.12)
            }
            Text(composer?.initial ?? "♪").font(.system(size: size * 0.57, weight: .regular, design: .serif))
                .foregroundStyle(GuideTheme.accent)
        }
        .frame(width: size, height: size).clipped().accessibilityHidden(true)
    }
}

struct WorkRow: View {
    let work: Work
    let catalog: Catalog
    @Environment(LearningStore.self) private var store
    var body: some View {
        HStack(spacing: 14) {
            ComposerMark(composer: catalog.composer(for: work))
            VStack(alignment: .leading, spacing: 5) {
                Text(work.title).font(.headline).foregroundStyle(.primary).fixedSize(horizontal: false, vertical: true)
                Text("\(catalog.composer(for: work)?.name ?? "") · 约 \(work.minutes) 分钟")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            if store.snapshot.listened.contains(work.id) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(GuideTheme.accent).accessibilityLabel("已听过")
            } else if store.snapshot.favorites.contains(work.id) {
                Image(systemName: "bookmark.fill").foregroundStyle(GuideTheme.accent).accessibilityLabel("已收藏")
            }
        }
        .padding(.vertical, 7)
        .accessibilityElement(children: .combine)
    }
}

struct WorkLink: View {
    let work: Work
    let catalog: Catalog
    var body: some View {
        NavigationLink { WorkDetailView(work: work, catalog: catalog) } label: {
            WorkRow(work: work, catalog: catalog)
        }
    }
}

struct SectionEyebrow: View {
    let title: String
    var body: some View {
        Text(title).font(.caption.weight(.semibold)).tracking(2).foregroundStyle(GuideTheme.accent)
    }
}

struct MusicStaff: View {
    var body: some View {
        Canvas { context, size in
            for i in 0..<5 {
                var line = Path()
                line.move(to: CGPoint(x: 0, y: size.height * 0.3 + CGFloat(i) * 10))
                line.addLine(to: CGPoint(x: size.width, y: size.height * 0.3 + CGFloat(i) * 10))
                context.stroke(line, with: .color(GuideTheme.accent.opacity(0.14)), lineWidth: 0.7)
            }
            for (i, step) in [2, 0, 1, 3, 2, 4, 1].enumerated() {
                let x = size.width * (CGFloat(i) + 0.6) / 7
                let y = size.height * 0.3 + CGFloat(step) * 10
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 12, height: 9)), with: .color(GuideTheme.accent.opacity(0.5)))
                var stem = Path()
                stem.move(to: CGPoint(x: x + 11, y: y + 4))
                stem.addLine(to: CGPoint(x: x + 11, y: y - 25))
                context.stroke(stem, with: .color(GuideTheme.accent.opacity(0.5)), lineWidth: 1)
            }
        }.frame(height: 92).accessibilityHidden(true)
    }
}
