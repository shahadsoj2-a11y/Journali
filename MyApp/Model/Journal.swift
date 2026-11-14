import Foundation

// ========== شكل البيانات ==========
struct Journal: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var date: Date
    var isBookmarked: Bool = false
}

// ========== التصنيف (خيارات الترتيب) ==========
enum SortOption {
    case byDate
    case byBookmark
}
