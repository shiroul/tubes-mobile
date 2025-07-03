/// Application-wide string constants and error messages
class AppStrings {
  // App Information
  static const String appName = 'LINA';
  static const String appFullName = 'Layanan Informasi Nasional Antisipasi Bencana';
  static const String appSubtitle = 'Layanan Informasi Nasional Antisipasi Bencana';

  // Authentication
  static const String signIn = 'Masuk';
  static const String signUp = 'Daftar';
  static const String signOut = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String forgotPassword = 'Lupa Password?';
  static const String createAccount = 'Buat Akun';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String profile = 'Profil';
  static const String reports = 'Laporan';
  static const String events = 'Bencana';
  static const String volunteers = 'Relawan';
  static const String add = 'Tambah';

  // Common Actions
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String submit = 'Kirim';
  static const String confirm = 'Konfirmasi';
  static const String back = 'Kembali';
  static const String next = 'Selanjutnya';
  static const String previous = 'Sebelumnya';
  static const String finish = 'Selesai';
  static const String close = 'Tutup';
  static const String retry = 'Coba Lagi';
  static const String refresh = 'Perbarui';

  // Status
  static const String active = 'Aktif';
  static const String inactive = 'Tidak Aktif';
  static const String pending = 'Menunggu';
  static const String approved = 'Disetujui';
  static const String rejected = 'Ditolak';
  static const String completed = 'Selesai';
  static const String available = 'Tersedia';
  static const String unavailable = 'Tidak Tersedia';
  static const String activeDuty = 'Tugas Aktif';

  // Volunteer Registration
  static const String registeredVolunteers = 'Relawan Terdaftar';
  static const String activeVolunteers = 'Aktif';
  static const String availableVolunteers = 'Tersedia';
  static const String volunteerRegistration = 'Pendaftaran Relawan';
  static const String selectRole = 'Pilih Peran Relawan';
  static const String registerAsVolunteer = 'Daftar Sebagai Relawan';

  // Disaster Types
  static const String flood = 'Banjir';
  static const String earthquake = 'Gempa Bumi';
  static const String fire = 'Kebakaran';
  static const String landslide = 'Tanah Longsor';
  static const String tornado = 'Angin Puting Beliung';
  static const String tsunami = 'Tsunami';
  static const String volcano = 'Gunung Berapi';

  // Severity Levels
  static const String severityHigh = 'Parah';
  static const String severityMedium = 'Sedang';
  static const String severityLow = 'Ringan';

  // Error Messages
  static const String errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  static const String errorAuth = 'Gagal melakukan autentikasi. Periksa kredensial Anda.';
  static const String errorPermission = 'Anda tidak memiliki izin untuk melakukan tindakan ini.';
  static const String errorNotFound = 'Data tidak ditemukan.';
  static const String errorValidation = 'Mohon lengkapi semua field yang diperlukan.';

  // Success Messages
  static const String successSave = 'Data berhasil disimpan.';
  static const String successUpdate = 'Data berhasil diperbarui.';
  static const String successDelete = 'Data berhasil dihapus.';
  static const String successSubmit = 'Data berhasil dikirim.';

  // Empty States
  static const String noDataFound = 'Tidak ada data ditemukan.';
  static const String noReportsFound = 'Tidak ada laporan ditemukan.';
  static const String noEventsFound = 'Tidak ada event ditemukan.';
  static const String noVolunteersFound = 'Tidak ada relawan ditemukan.';

  // Loading States
  static const String loading = 'Memuat...';
  static const String processing = 'Memproses...';
  static const String submitting = 'Mengirim...';
  static const String updating = 'Memperbarui...';

  // Volunteer Roles
  static const String medicalRole = 'Medis';
  static const String logisticsRole = 'Logistik';
  static const String evacuationRole = 'Evakuasi';
  static const String mediaRole = 'Media';
  static const String generalAssistanceRole = 'Bantuan Umum';
}
