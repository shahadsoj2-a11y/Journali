import Foundation
import Combine
 
class JournalViewModel: ObservableObject {
 
    // ========== البيانات ==========
    @Published var journals: [Journal] = []
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .byDate
 
    // ========== اليوميات اللي تنعرض ==========
    var shownJournals: [Journal] {
        var result = journals
 
        // البحث
        if searchText.isEmpty == false {
            result = result.filter { journal in
                journal.title.localizedCaseInsensitiveContains(searchText)
            }
        }
 
        // الترتيب
        if sortOption == .byBookmark {
            result = result.sorted { first, second in
                first.isBookmarked && !second.isBookmarked
            }
        } else {
            result = result.sorted { first, second in
                first.date > second.date
            }
        }
 
        return result
    }
 
    // ========== Functions ==========
 
    func addJournal(title: String, content: String) {
        let newJournal = Journal(title: title, content: content, date: Date())
        journals.append(newJournal)
    }
 
    func updateJournal(_ journal: Journal, title: String, content: String) {
        if let index = journals.firstIndex(where: { $0.id == journal.id }) {
            journals[index].title = title
            journals[index].content = content
        }
    }
 
    // يحفظ اليومية: إذا موجودة يعدّلها، وإذا جديدة يضيفها
    func saveJournal(_ journal: Journal?, title: String, content: String) {
        if let journal = journal {
            updateJournal(journal, title: title, content: content)
        } else {
            addJournal(title: title, content: content)
        }
    }
 
    func deleteJournal(_ journal: Journal) {
        journals.removeAll { $0.id == journal.id }
    }
 
    func toggleBookmark(_ journal: Journal) {
        if let index = journals.firstIndex(where: { $0.id == journal.id }) {
            journals[index].isBookmarked.toggle()
        }
    }
}
 
