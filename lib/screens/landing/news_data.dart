import 'package:flutter/material.dart';

/// Satu artikel berita/pengumuman sekolah.
class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.category,
    required this.title,
    required this.excerpt,
    required this.date,
    required this.author,
    required this.photo,
    required this.color,
    required this.icon,
    required this.body,
  });

  final String id;
  final String category;
  final String title;
  final String excerpt;
  final String date;
  final String author;

  /// ID foto Unsplash (`photo-xxxxxxxx`).
  final String photo;
  final Color color;
  final IconData icon;

  /// Isi artikel per paragraf.
  final List<String> body;

  /// URL gambar dengan lebar [w] piksel.
  String imageUrl(int w) =>
      'https://images.unsplash.com/$photo?auto=format&fit=crop&w=$w&q=70';
}

const List<NewsArticle> kNewsArticles = [
  NewsArticle(
    id: 'lks-juara-provinsi',
    category: 'Prestasi',
    title: 'SMK N 1 Pati Raih Juara 1 LKS Tingkat Provinsi Jawa Tengah',
    excerpt:
        'Tim siswa jurusan Teknik Otomotif berhasil meraih juara pertama dalam ajang Lomba Kompetensi Siswa (LKS) tingkat Provinsi Jawa Tengah yang diselenggarakan di Semarang.',
    date: '18 Mei 2026',
    author: 'Humas SMK N 1 Pati',
    photo: 'photo-1567427017947-545c5f8d16ad',
    color: Colors.green,
    icon: Icons.emoji_events_outlined,
    body: [
      'Prestasi membanggakan kembali ditorehkan oleh siswa SMK Negeri 1 Pati. Tim dari jurusan Teknik Otomotif berhasil meraih Juara 1 dalam ajang Lomba Kompetensi Siswa (LKS) tingkat Provinsi Jawa Tengah yang diselenggarakan di Semarang pada 15–17 Mei 2026.',
      'Kompetisi ini diikuti oleh perwakilan terbaik dari seluruh kabupaten/kota di Jawa Tengah. Dalam bidang Automobile Technology, siswa SMK N 1 Pati menunjukkan penguasaan teknis yang matang mulai dari diagnosa kerusakan mesin, perawatan berkala, hingga perbaikan sistem kelistrikan kendaraan.',
      '"Keberhasilan ini adalah buah dari latihan rutin, bimbingan guru produktif, serta dukungan fasilitas bengkel yang memadai," ujar Kepala SMK Negeri 1 Pati saat menyambut kepulangan tim di sekolah.',
      'Dengan capaian ini, sekolah berhak mewakili Provinsi Jawa Tengah pada ajang LKS tingkat nasional. Pihak sekolah berharap prestasi ini dapat memotivasi seluruh siswa untuk terus mengasah kompetensi sesuai bidang keahliannya.',
    ],
  ),
  NewsArticle(
    id: 'ppdb-2026-2027',
    category: 'Pengumuman',
    title: 'Pendaftaran Peserta Didik Baru Tahun Ajaran 2026/2027 Dibuka',
    excerpt:
        'Pendaftaran Peserta Didik Baru (PPDB) untuk tahun ajaran 2026/2027 resmi dibuka. Calon siswa dapat mendaftar secara online melalui portal pendaftaran sekolah.',
    date: '10 Mei 2026',
    author: 'Panitia PPDB',
    photo: 'photo-1577896851231-70ef18881754',
    color: Colors.blue,
    icon: Icons.assignment_ind_outlined,
    body: [
      'SMK Negeri 1 Pati resmi membuka Pendaftaran Peserta Didik Baru (PPDB) untuk Tahun Ajaran 2026/2027. Pendaftaran dapat dilakukan secara daring melalui portal resmi sekolah sehingga lebih mudah, cepat, dan transparan.',
      'Tersedia beberapa program keahlian unggulan, antara lain Rekayasa Perangkat Lunak (RPL), Teknik Komputer dan Jaringan (TKJ), serta Teknik Otomotif. Setiap program dirancang mengikuti kebutuhan dunia industri terkini.',
      'Calon peserta didik cukup menyiapkan dokumen seperti kartu keluarga, ijazah/SKL, akta kelahiran, dan pas foto. Seluruh berkas diunggah melalui formulir pendaftaran online pada menu "Daftar Sekarang".',
      'Jadwal seleksi serta pengumuman hasil akan diinformasikan melalui website dan media sosial resmi sekolah. Untuk pertanyaan lebih lanjut, calon siswa dapat menghubungi panitia PPDB pada jam kerja.',
    ],
  ),
  NewsArticle(
    id: 'pkl-batch-2',
    category: 'Kegiatan',
    title: 'Praktik Kerja Lapangan Batch 2 Resmi Dimulai',
    excerpt:
        'Sebanyak 120 siswa kelas XI mengikuti program Praktik Kerja Lapangan (PKL) di berbagai perusahaan mitra sekolah di wilayah Pati, Kudus, dan Rembang.',
    date: '3 Mei 2026',
    author: 'Hubungan Industri',
    photo: 'photo-1522202176988-66273c2fd55f',
    color: Colors.orange,
    icon: Icons.work_outline,
    body: [
      'Sebanyak 120 siswa kelas XI SMK Negeri 1 Pati resmi memulai program Praktik Kerja Lapangan (PKL) Batch 2. Kegiatan ini berlangsung selama tiga bulan di berbagai perusahaan mitra sekolah yang tersebar di wilayah Pati, Kudus, dan Rembang.',
      'PKL merupakan bagian penting dari kurikulum SMK yang bertujuan memberikan pengalaman kerja nyata kepada siswa. Melalui program ini, siswa dapat menerapkan kompetensi yang dipelajari di sekolah sekaligus mengenal budaya kerja industri.',
      'Sebelum diterjunkan, seluruh peserta mengikuti pembekalan terkait etika kerja, keselamatan dan kesehatan kerja (K3), serta target kompetensi yang harus dicapai selama penempatan.',
      'Sekolah menjalin kerja sama dengan puluhan dunia usaha dan dunia industri (DUDI) untuk memastikan siswa memperoleh tempat PKL yang relevan dengan jurusannya. Selama kegiatan, siswa tetap dibimbing oleh guru pembimbing dan mentor dari perusahaan.',
    ],
  ),
];

NewsArticle? newsById(String id) {
  for (final a in kNewsArticles) {
    if (a.id == id) return a;
  }
  return null;
}
