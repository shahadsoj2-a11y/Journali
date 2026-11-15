import SwiftUI
 
// الأرقام [1] إلى [8] تشير لنقاط الجدول المطلوبة
 
// ==============================
// الصفحة الرئيسية
// ==============================
struct ContentView: View {
    // [3] @StateObject: نسوي الـ ViewModel هنا لأول مرة
    @StateObject var viewModel = JournalViewModel()
 
    // [3] @State: متغيرات خاصة بهذي الشاشة
    @State private var showSplash = true                 // هل نعرض شاشة البداية؟
    @State private var showNewJournal = false            // هل صفحة الكتابة مفتوحة؟
    @State private var journalToEdit: Journal? = nil     // اليومية اللي نعدلها
    @State private var journalToDelete: Journal? = nil   // اليومية اللي نحذفها
    @State private var showDeleteAlert = false           // هل تنبيه الحذف ظاهر؟
 
    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    // بعد ثانيتين نخفي شاشة البداية
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showSplash = false }
                    }
                }
        } else {
            homeScreen
        }
    }
 
    var homeScreen: some View {
        // [2] NavigationStack: يعطينا العنوان والأزرار اللي فوق
        NavigationStack {
            // [1] ZStack: طبقات فوق بعض
            ZStack {
                if viewModel.journals.isEmpty {
                    // [8] Empty State: ما فيه يوميات
                    EmptyStateView()
                } else {
                    // [1] List: قائمة اليوميات
                    List {
                        ForEach(viewModel.shownJournals) { journal in
                            JournalCard(journal: journal) {
                                viewModel.toggleBookmark(journal)
                            }
                            .onTapGesture {
                                journalToEdit = journal          // نفتحها للتعديل
                            }
                            // [6] السحب لليسار يطلع زر الحذف
                            .swipeActions {
                                Button {
                                    journalToDelete = journal
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash.fill")
                                }
                                .tint(Color.deleteRed)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Journal")
            .toolbarTitleDisplayMode(.inlineLarge)
            // [5] شريط البحث تحت الشاشة
            .safeAreaInset(edge: .bottom) {
                SearchBar(text: $viewModel.searchText)
            }
            // [2] Toolbar: الأزرار اللي فوق
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // [5] قائمة الترتيب
                    Menu {
                        Button("Sort by Bookmark") {
                            viewModel.sortOption = .byBookmark
                        }
                        Button("Sort by Entry Date") {
                            viewModel.sortOption = .byDate
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
 
                    // زر الإضافة ➕
                    Button {
                        showNewJournal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // [2] sheet: صفحة كتابة يومية جديدة
            .sheet(isPresented: $showNewJournal) {
                EditorView(viewModel: viewModel, journal: nil)
            }
            // [2] sheet: صفحة تعديل يومية موجودة
            .sheet(item: $journalToEdit) { journal in
                EditorView(viewModel: viewModel, journal: journal)
            }
            // [6] [8] تنبيه قبل الحذف
            .alert("Delete Journal?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let journal = journalToDelete {
                        viewModel.deleteJournal(journal)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this journal?")
            }
        }
    }
}
 
// ==============================
// [5] شريط البحث
// ==============================
struct SearchBar: View {
    // [3] @Binding: رابط لمتغير searchText اللي في الـ ViewModel
    // لما المستخدم يكتب هنا، يتغير هناك
    @Binding var text: String
 
    var body: some View {
        // [1] HStack: العدسة والكتابة جنب بعض
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
 
            TextField("Search", text: $text)
        }
        .padding()
        .glassEffect()          // خلفية زجاجية شفافة مثل التصميم
        .padding(.horizontal)
    }
}
 
// ==============================
// شاشة البداية
// ==============================
struct SplashView: View {
    var body: some View {
        // [1] VStack: العناصر فوق بعض
        VStack(spacing: 16) {
            Image(.notebook)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
 
            Text("Journali")
                .font(.largeTitle)
                .fontWeight(.black)
 
            Text("Your thoughts, your story")
                .font(.body)
                .fontWeight(.light)
        }
    }
}
 
// ==============================
// [8] الشاشة الفاضية
// ==============================
struct EmptyStateView: View {
    var body: some View {
        // [1] ScrollView: محتوى ينسحب بالإصبع
        ScrollView {
            VStack(spacing: 16) {
                Image(.book)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
 
                Text("Begin Your Journal")
                    .font(.title2.bold())
                    .foregroundStyle(Color.lightPurple)
 
                Text("Craft your personal diary, tap the plus icon to begin")
                    .font(.body)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .containerRelativeFrame(.vertical)   // يخلي المحتوى في نص الشاشة
        }
    }
}
 
// ==============================
// بطاقة اليومية
// ==============================
struct JournalCard: View {
    let journal: Journal
    let onBookmark: () -> Void      // وش يصير لما ينضغط زر الحفظ
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // [1] HStack: العنوان وزر الحفظ جنب بعض
            HStack {
                Text(journal.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.lightPurple)
 
                Spacer()
 
                Button {
                    onBookmark()
                } label: {
                    if journal.isBookmarked {
                        Image(systemName: "bookmark.fill")
                    } else {
                        Image(systemName: "bookmark")
                    }
                }
                .buttonStyle(.borderless)
                .font(.title2)
                .foregroundStyle(Color.lightPurple)
            }
 
            Text(journal.date.formatted(date: .numeric, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
 
            Text(journal.content)
                .font(.body)
                .lineLimit(5)
                .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}
 
// ==============================
// [7] صفحة الكتابة (جديدة أو تعديل)
// ==============================
struct EditorView: View {
    @Environment(\.dismiss) var dismiss     // عشان نسكّر الصفحة
 
    // [3] @ObservedObject: نستقبل الـ ViewModel من ContentView
    @ObservedObject var viewModel: JournalViewModel
 
    var journal: Journal?       // nil = يومية جديدة
 
    @State private var title = ""
    @State private var content = ""
    @State private var showDiscardAlert = false
 
    // [8] نتحكم وين يطلع الكيبورد
    @FocusState private var titleFocused: Bool
    @FocusState private var contentFocused: Bool
 
    // التاريخ: إذا تعديل نعرض تاريخ اليومية، وإذا جديدة تاريخ اليوم
    var shownDate: Date {
        if let journal = journal {
            return journal.date
        } else {
            return Date()
        }
    }
 
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                // [7] TextField: خانة سطر واحد للعنوان
                TextField("Title", text: $title)
                    .font(.largeTitle.bold())
                    .focused($titleFocused)
 
                Text(shownDate.formatted(date: .numeric, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
 
                // [7] TextEditor: خانة كبيرة للمحتوى
                TextEditor(text: $content)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)   // [8] تسحب لتحت يختفي الكيبورد
                    .focused($contentFocused)
                    // النص الرمادي يطلع إذا الخانة فاضية
                    .overlay(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Type here...")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
                    .font(.title3)
                    .padding(.top, 16)
            }
            .padding()
            .toolbar {
                // [7] زر الإلغاء X
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if title.isEmpty && content.isEmpty {
                            dismiss()                   // ما فيه شي مكتوب: نسكّر على طول
                        } else {
                            showDiscardAlert = true     // فيه كلام: نسأل أول
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
 
                // [7] زر الحفظ ✓
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if title.isEmpty == false {     // ما نحفظ بدون عنوان
                            viewModel.saveJournal(journal, title: title, content: content)   // [4] الحفظ في الـ ViewModel
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.lightPurple)    // لون الزر موف
                }
            }
            // [6] [8] تنبيه قبل تجاهل التعديلات
            .alert("Are you sure you want to discard changes on this journal?", isPresented: $showDiscardAlert) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) { }
            }
        }
        .onAppear {
            if let journal = journal {
                // تعديل: نعبّي الخانات، والكيبورد يطلع على المحتوى
                title = journal.title
                content = journal.content
                contentFocused = true
            } else {
                // جديدة: الكيبورد يطلع على العنوان
                titleFocused = true
            }
        }
    }
}
 
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
 
