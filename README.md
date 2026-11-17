# latres

A new Flutter project.

lib/
├── main.dart                  # Titik awal aplikasi, Route Guard (cek sesi login)
├── theme.dart                 # Styling tema terpusat (Warna, Font, Input, Button)
├── models/                    # Representasi objek data (DTO)
│   ├── character.dart         # Model Character (id, name, status, image, dll)
│   └── episode.dart           # Model Episode
├── services/                  # Komunikasi data eksternal & lokal
│   ├── db_service.dart        # SQLite Database (CRUD Tabel User, SHA-256)
│   ├── auth_service.dart      # SharedPreferences (Session Sesi Login)
│   └── api_service.dart       # HTTP Client (Panggilan API Rick and Morty)
├── stores/                    # State Management aplikasi
│   └── favorite_store.dart    # ChangeNotifier Singleton (Sinkronisasi Favorit)
├── widgets/                   # Komponen UI yang dipakai berulang
│   └── common_widgets.dart    # CharacterCard, StatusDot, ErrorView, EmptyView
└── screens/                   # Halaman / Tampilan Antarmuka
    ├── login_screen.dart      # Form Login
    ├── register_screen.dart   # Form Registrasi
    ├── main_shell.dart        # Bottom Navigation Bar (IndexedStack) + Logout
    ├── home_screen.dart       # Daftar Karakter, Search (Debounce), Filter & Pagination
    ├── detail_screen.dart     # Detail Karakter (SliverAppBar) & Aksi Favorit
    ├── favorite_screen.dart   # Daftar Favorit dengan Dismissible (Swipe to Delete)
    └── episode_screen.dart    # Daftar Episode + Pagination
    
