import SwiftUI

struct ListeningGuideView: View {
    private let tips = [
        ("从短的开始", "先用三五分钟认识一个声音，再慢慢走进完整的协奏曲与交响曲。"),
        ("一次只留意一件事", "第一遍听旋律，第二遍听乐器之间的对话，第三遍留意结构与变化。"),
        ("给动态留一点空间", "找一个安静的环境，以舒适的音量聆听。不要为了听清弱音而把音量调得过高。"),
        ("可以跳过，也可以回来", "暂时没感觉很正常。记下你的第一印象，过一阵再听，感受可能会变。"),
        ("比较不同的演绎", "同一部作品会有许多录音。速度、音色与停顿不同，作品也会呈现新的面貌。")
    ]
    private let terms = [
        ("Largo", "广板", "宽广、缓慢"), ("Adagio", "柔板", "缓慢、从容"),
        ("Andante", "行板", "如行走般流动"), ("Moderato", "中板", "适中的速度"),
        ("Allegretto", "小快板", "略快，通常比 Allegro 舒缓"), ("Allegro", "快板", "快而活泼"),
        ("Vivace", "活泼的", "生动、轻快"), ("Presto", "急板", "很快")
    ]
    var body: some View {
        List {
            Section("把聆听变成自己的习惯") {
                ForEach(tips, id: \.0) { tip in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tip.0).font(.headline)
                        Text(tip.1).font(.body).foregroundStyle(.secondary).lineSpacing(4)
                    }.padding(.vertical, 8)
                }
            }
            Section {
                ForEach(terms, id: \.0) { term in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(term.0) · \(term.1)").font(.system(.headline, design: .serif))
                        Text(term.2).font(.subheadline).foregroundStyle(.secondary)
                    }.padding(.vertical, 4)
                }
            } header: { Text("速度术语小词典") } footer: { Text("这些词也提示音乐的性格；具体速度取决于作品、时代与演绎，不是一组固定的每分钟拍数。") }
        }.navigationTitle("聆听手册").navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden).background(GuideTheme.paper)
    }
}
