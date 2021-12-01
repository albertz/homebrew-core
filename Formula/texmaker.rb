class Texmaker < Formula
  desc "Free cross-platform LaTeX editor since 2003"
  homepage "https://www.xm1math.net/texmaker/"
  url "https://www.xm1math.net/texmaker/texmaker-5.1.2.tar.bz2"
  sha256 "526896f2c1ae561130eec7aae815b9dcda9e8eeb772b6541d0dc94ce91a71044"
  license "GPL-2.0-only"

  depends_on xcode: :build
  depends_on "qt"

  on_linux do
    depends_on "gcc"
  end

  fails_with gcc: "5"

  patch :p0, :DATA

  def install
    args = [
      "PREFIX=#{prefix}",
      "DESKTOPDIR=#{share}/applications",
      "ICONDIR=#{share}/pixmaps",
      "METAINFODIR=#{share}/metainfo",
      "QMAKE_CXXFLAGS=#{ENV.cxxflags}",
      "-config", "release",
      "-spec"
    ]
    os = OS.mac? ? "macx" : OS.kernel_name.downcase
    compiler = ENV.compiler.to_s.start_with?("gcc") ? "g++" : ENV.compiler
    args << "#{os}-#{compiler}"

    system Formula["qt"].opt_bin/"qmake", *args
    system "make"
    system "make", "install"

    prefix.install "Texmaker.app" if OS.mac?
  end

  test do
    if OS.mac?
      assert_predicate prefix/"Texmaker.app", :exist?, "Texmaker.app must exist"
      assert_predicate prefix/"Texmaker.app/Contents/MacOS/texmaker", :executable?
    else
      assert_predicate bin/"texmaker", :exist?, "texmaker must exist"
      assert_predicate bin/"texmaker", :executable?, "texmaker must be executable"
    end
  end
end

__END__
--- icondelegate.cpp.old	2021-12-01 18:56:51.990313349 +0000
+++ icondelegate.cpp	2021-12-01 19:06:14.410557704 +0000
@@ -335,9 +335,11 @@
     //QString key;
     //key.sprintf("%d-%d", pixmap.serialNumber(), enabled);
     QString key = qPixmapSerial(pixmap.cacheKey(), enabled);
-    QPixmap *pm = QPixmapCache::find(key);
-//    QPixmap *pm;
-//    QPixmapCache::find(key,pm);
+    QPixmap *pm = new QPixmap();
+    if(QPixmapCache::find(key, pm))
+        return pm;
+    delete pm;
+    pm = NULL;
     if (!pm) {
         QImage img = pixmap.toImage().convertToFormat(QImage::Format_ARGB32_Premultiplied);

