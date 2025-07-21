// ================================================
// ANIMASI WARISAN NUSANTARA - VERSI IMPROVED
// oleh Gemini
// ================================================

import ddf.minim.*;

Minim minim;
AudioPlayer player;
AudioPlayer backsound;

// === Konfigurasi & Variabel Global ===
PFont fontTitle, fontSub;
float titleAlpha = 0;
float subAlpha = 0;

// Variabel untuk elemen animasi pembuka
float cloud1X, cloud2X, cloud3X;
float mountainParallax = 0;

// === Manajemen Scene & Transisi ===
ArrayList<Scene> scenes; // Menyimpan semua scene rumah adat
int currentSceneIndex = -1; // -1 untuk scene pembuka
int sceneStartTime;
int transitionState = 0; // 0: normal, 1: fading out, 2: fading in
float transitionAlpha = 0;
final int TRANSITION_DURATION = 500; // Durasi transisi (ms)

// === Optimasi Grafis ===
PGraphics openingBackground; // Buffer untuk background pembuka yang statis

// === Variabel Animasi Karakter ===
boolean isBlinking = false;
long lastBlinkTime = 0;
int blinkInterval = 3000; // Interval dasar 3 detik
final int BLINK_DURATION = 150; // Lamanya mata tertutup (ms)

// Tambahkan variabel global untuk delay audio
int audioDelayMs = 5000;
boolean audioPlayed = false;
int programStartTime;

// === Kelas untuk merepresentasikan satu scene ===
class Scene {
  PImage bgImage;
  String title;
  String subtitle;
  int duration; // dalam milidetik
  
  float bimoX, bimoY;
  float raraX, raraY;
  float bimoScale, raraScale;

  Scene(String imgPath, String title, String subtitle, int duration, float bX, float bY, float rX, float rY, float bS, float rS) {
    this.bgImage = loadImage(imgPath);
    this.title = title;
    this.subtitle = subtitle;
    this.duration = duration;
    // Simpan posisi yang diterima ke dalam variabel
    this.bimoX = bX;
    this.bimoY = bY;
    this.raraX = rX;
    this.raraY = rY;
    this.bimoScale = bS; 
    this.raraScale = rS;
  }

  void draw(boolean blinking) {
    // Gambar background putih dan langit biru
    if (bgImage == null) {
      drawSkyBackground();
      drawMountainsWithParallax();
      drawCloudsProfessional();
      drawTreesWithSway();
      drawBirds();
      // Karakter di tengah
      drawBimo(this.bimoX, this.bimoY, this.bimoScale, blinking);
      drawRara(this.raraX, this.raraY, this.raraScale, blinking);
      // Teks ending
      textAlign(CENTER, CENTER);
      textFont(fontTitle, 44);
      fill(0, 180);
      text("Terima Kasih Sudah Menjelajahi\nWarisan Budaya Nusantara!", width/2+3, height*0.32+3);
      fill(255, 255, 220);
      text("Terima Kasih Sudah Menjelajahi\nWarisan Budaya Nusantara!", width/2, height*0.32);
    } else {
      // Tampilkan background gambar rumah adat
      drawSkyBackground();
      if (bgImage != null) {
        image(bgImage, 0, 0, width, height);
      }
      drawBirds();
      drawBimo(this.bimoX, this.bimoY, this.bimoScale, blinking);
      drawRara(this.raraX, this.raraY, this.raraScale, blinking);
      drawInfoBox(this.title, this.subtitle);
    }
  }
}

// ==================== SETUP ====================
void setup() {
  size(1280, 720);
  frameRate(60);

  // Load font
  fontTitle = createFont("Georgia Bold", 52);
  fontSub = createFont("Georgia", 32);

  // Inisialisasi posisi awan
  cloud1X = 200;
  cloud2X = 600;
  cloud3X = 1000;

  // Buat buffer grafis untuk background pembuka (Optimasi!)
  openingBackground = createGraphics(width, height);
  drawOpeningBackgroundOnce(openingBackground);

  // Inisialisasi daftar scene menggunakan ArrayList
  scenes = new ArrayList<Scene>();
  scenes.add(new Scene("Rumah_adat_joglo.jpeg", "Rumah Adat Joglo", "Asal: Jawa Tengah & Yogyakarta", 25000, 
                       width * 0.15, height * 0.8, width * 0.85, height * 0.8, 1.3, 1.3));
                       
  // Contoh: Di depan Tongkonan, mereka lebih ke tengah
  scenes.add(new Scene("Rumah_adat_tongkonan.png", "Rumah Adat Tongkonan", "Asal: Tana Toraja, Sulawesi Selatan", 25000,
                       width * 0.58, height * 0.50, width * 0.45, height * 0.60, 1.0, 1.3));
                       
  // Contoh: Di depan Rumah Gadang, Rara sedikit di depan Bimo
  scenes.add(new Scene("Rumah_adat_padang.png", "Rumah Adat Minangkabau", "Asal: Minangkabau, Sumatera Barat", 40000,
                       width * 0.67, height * 0.65, width * 0.82, height * 0.65, 1.5, 1.5));
                       
  // Contoh: Di depan Honai, mereka berdiri sangat dekat
  scenes.add(new Scene("Rumah_adat_honai.png", "Rumah Adat Honai", "Asal: Suku Dani, Papua", 40000,
                       width * 0.53, height * 0.60, width * 0.65, height * 0.60, 1.3, 1.3));

  // Scene Ending: Karakter di tengah, background putih & langit biru, burung-burung, tanpa gambar rumah adat
  scenes.add(new Scene("", "Terima Kasih!", "Sudah Menjelajahi Warisan Budaya Nusantara", 15000,
                       width * 0.45, height * 0.7, width * 0.55, height * 0.7, 1.4, 1.4));
  
  sceneStartTime = millis();

  // Inisialisasi dan mainkan audio voice.mp3 (tapi delay 5 detik)
  minim = new Minim(this);
  player = minim.loadFile("voice.mp3");
  // Jangan langsung play, tunggu 5 detik di draw()
  programStartTime = millis();

  // Inisialisasi dan mainkan backsound looping
  backsound = minim.loadFile("backsound.mp3");
  backsound.loop();
  backsound.setGain(-20); // volume lebih kecil (sekitar 25%)

  // Atur volume voice.mp3 ke 100% (default, tidak perlu setGain, tapi bisa dipastikan)
  player.setGain(0); // 0 dB = 100%
}

// ==================== DRAW (LOOP UTAMA) ====================
void draw() {
  // Play audio setelah 5 detik
  if (!audioPlayed && millis() - programStartTime > audioDelayMs) {
    player.play();
    audioPlayed = true;
  }
  if (!isBlinking && millis() - lastBlinkTime > blinkInterval) {
    isBlinking = true;
    lastBlinkTime = millis(); // Catat waktu mulai berkedip
  }
  // Cek apakah kedipan sudah selesai
  if (isBlinking && millis() - lastBlinkTime > BLINK_DURATION) {
    isBlinking = false;
    // Atur interval kedipan berikutnya secara acak agar natural
    blinkInterval = 3000 + (int)random(-500, 500); 
  }
  
  //logic scene
  if (currentSceneIndex == -1) {
    // === Scene Pembuka ===
    drawOpeningScene();
    if (millis() - sceneStartTime > 63000) { // Durasi scene pembuka 63 detik
      startTransitionToNextScene();
    }
  } else {
    // === Scene Rumah Adat ===
    // Gambar scene saat ini
    scenes.get(currentSceneIndex).draw(isBlinking);

    // Cek durasi untuk pindah ke scene berikutnya
    if (transitionState == 0 && millis() - sceneStartTime > scenes.get(currentSceneIndex).duration) {
      startTransitionToNextScene();
    }
  }
  
  // Kelola transisi antar scene
  handleTransition();
}

// Fungsi untuk menggambar background pembuka sekali saja (Optimasi)
void drawOpeningBackgroundOnce(PGraphics pg) {
  pg.beginDraw();
  // Langit gradasi
  pg.noStroke();
  for (int y = 0; y < pg.height * 0.8; y++) {
    float t = map(y, 0, pg.height * 0.8, 0, 1);
    color c = lerpColor(color(70, 170, 255), color(220, 240, 255), t);
    pg.stroke(c);
    pg.line(0, y, pg.width, y);
  }
  // Rumput gradasi
  for (int y = (int)(pg.height * 0.75); y < pg.height; y++) {
    float t = map(y, pg.height * 0.75, pg.height, 0, 1);
    color c = lerpColor(color(120, 200, 120), color(60, 140, 60), t);
    pg.stroke(c);
    pg.line(0, y, pg.width, y);
  }
  pg.endDraw();
}

// ==================== FUNGSI-FUNGSI SCENE ====================

void drawOpeningScene() {
  // Tampilkan background yang sudah di-render sebelumnya
  image(openingBackground, 0, 0);

  // Gambar elemen dinamis
  drawMountainsWithParallax();
  drawTreesWithSway();
  drawCloudsProfessional();
  drawBirds();
  // Panggil fungsi gambar karakter dengan status kedipan
  drawBimo(width * 0.30, height - 280, 1.3, isBlinking);
  drawRara(width * 0.70, height - 300, 1.3, isBlinking);
  //drawCharactersProfessional(width * 0.25, height - 120, 1.1); // Bimo
  //drawCharactersProfessional(width * 0.75, height - 120, 1.1); // Rara
  drawTextsOpening();
  drawOrnament();
}

void drawInfoBox(String title, String subtitle) {
  pushStyle();
  rectMode(CENTER);
  fill(0, 150); // Kotak hitam transparan
  noStroke();
  rect(width / 2, height - 80, 750, 90, 25); // Kotak lebih besar dan bulat

  // Teks
  textAlign(CENTER, CENTER);
  fill(255);
  textFont(fontTitle, 36);
  text(title, width / 2, height - 95);
  textFont(fontSub, 24);
  text(subtitle, width / 2, height - 55);
  popStyle();
}


// ==================== MANAJEMEN TRANISIS & SCENE ====================

void startTransitionToNextScene() {
  transitionState = 1; // Mulai fading out
  sceneStartTime = millis(); // Reset timer untuk transisi
}

void handleTransition() {
  if (transitionState == 0) return;

  float elapsedTime = millis() - sceneStartTime;

  if (transitionState == 1) { // Fading out
    transitionAlpha = map(elapsedTime, 0, TRANSITION_DURATION, 0, 255);
    if (transitionAlpha >= 255) {
      transitionAlpha = 255;
      transitionState = 2; // Ganti ke fading in
      currentSceneIndex = (currentSceneIndex + 1) % scenes.size(); // Pindah ke scene selanjutnya
      sceneStartTime = millis(); // Reset timer untuk scene baru
    }
  } else if (transitionState == 2) { // Fading in
    transitionAlpha = map(elapsedTime, 0, TRANSITION_DURATION, 255, 0);
    if (transitionAlpha <= 0) {
      transitionAlpha = 0;
      transitionState = 0; // Transisi selesai
      sceneStartTime = millis(); // Mulai hitung durasi scene
    }
  }

  // Gambar layar hitam transparan untuk efek fade
  fill(0, transitionAlpha);
  noStroke();
  rect(0, 0, width, height);
}

// Lewati scene jika mouse ditekan
void mousePressed() {
  if (transitionState == 0) { // Hanya bisa skip jika tidak sedang transisi
    startTransitionToNextScene();
  }
}


// ==================== PENINGKATAN VISUAL & ANIMASI ====================

void drawSkyBackground() {
  // Gambar background putih untuk seluruh layar
  fill(255);
  noStroke();
  rect(0, 0, width, height);
  
  // Gambar langit biru gradasi di bagian atas
  for (int y = 0; y < height * 0.6; y++) {
    float t = map(y, 0, height * 0.6, 0, 1);
    color c = lerpColor(color(135, 206, 235), color(255, 255, 255), t);
    stroke(c);
    line(0, y, width, y);
  }
}

void drawMountainsWithParallax() {
  // Efek parallax: gunung bergerak sedikit lebih lambat dari foreground
  mountainParallax = map(sin(frameCount * 0.005), -1, 1, -15, 15);
  
  // Gunung belakang
  noStroke();
  beginShape();
  fill(180, 210, 240);
  vertex(0 - 20 + mountainParallax * 0.5, height * 0.62);
  bezierVertex(width * 0.18 + mountainParallax * 0.5, height * 0.50, width * 0.32 + mountainParallax * 0.5, height * 0.60, width * 0.5 + mountainParallax * 0.5, height * 0.54);
  bezierVertex(width * 0.68 + mountainParallax * 0.5, height * 0.48, width * 0.82 + mountainParallax * 0.5, height * 0.60, width + 20 + mountainParallax * 0.5, height * 0.58);
  vertex(width, height);
  vertex(0, height);
  endShape(CLOSE);

  // Gunung depan
  beginShape();
  fill(120, 180, 140);
  vertex(0 - 20 + mountainParallax, height * 0.72);
  bezierVertex(width * 0.22 + mountainParallax, height * 0.66, width * 0.38 + mountainParallax, height * 0.74, width * 0.52 + mountainParallax, height * 0.68);
  bezierVertex(width * 0.7 + mountainParallax, height * 0.62, width * 0.85 + mountainParallax, height * 0.74, width + 20 + mountainParallax, height * 0.70);
  vertex(width, height);
  vertex(0, height);
  endShape(CLOSE);
}

void drawTreesWithSway() {
  // Goyangan halus pada pohon menggunakan noise()
  float sway = map(noise(frameCount * 0.02), 0, 1, -0.02, 0.02);
  drawTree(110, height - 20, 2.1, sway);
  drawTree(width - 110, height - 20, 2.1, -sway);
}

// Fungsi pohon yang digeneralisasi
void drawTree(float x, float y, float s, float sway) {
  pushMatrix();
  translate(x, y);
  scale(s);
  rotate(sway); // Tambahkan goyangan
  
  // Batang & Cabang
  stroke(80, 60, 30, 220);
  noFill();
  strokeWeight(10);
  bezier(0, 0, -8, -30, 10, -60, 0, -100);
  strokeWeight(6);
  bezier(0, -40, -18, -60, -18, -80, -8, -100);
  bezier(0, -60, 18, -80, 28, -100, 18, -120);
  
  // Kanopi Daun
  noStroke();
  fill(40, 100, 60, 240);
  ellipse(0, -110, 90, 54);
  ellipse(-30, -100, 54, 38);
  ellipse(30, -100, 54, 38);
  ellipse(-18, -128, 38, 28);
  ellipse(18, -128, 38, 28);
  ellipse(0, -140, 44, 24);
  popMatrix();
}


// ==========================================================
// KODE GAMBAR ASLI ANDA (HANYA DENGAN SEDIKIT PENYESUAIAN)
// Tidak perlu banyak diubah karena sudah cukup baik.
// ==========================================================

void drawOrnament() {
  pushMatrix();
  translate(40, 40);
  for (int i = 0; i < 3; i++) {
    float s = 32 - i * 8;
    stroke(210, 180, 120, 90 - i * 20);
    strokeWeight(3 - i);
    noFill();
    beginShape();
    for (int a = 0; a < 8; a++) {
      float angle = a * TWO_PI / 8.0;
      float r = s + (a % 2 == 0 ? 8 : 0);
      vertex(cos(angle) * r, sin(angle) * r);
    }
    endShape(CLOSE);
  }
  popMatrix();
  pushMatrix();
  translate(width - 40, height - 40);
  for (int i = 0; i < 3; i++) {
    float s = 28 - i * 7;
    stroke(210, 180, 120, 70 - i * 18);
    strokeWeight(2.5 - i * 0.7);
    noFill();
    beginShape();
    for (int a = 0; a < 6; a++) {
      float angle = a * TWO_PI / 6.0;
      float r = s + (a % 2 == 0 ? 6 : 0);
      vertex(cos(angle) * r, sin(angle) * r);
    }
    endShape(CLOSE);
  }
  popMatrix();
}

void drawCloudsProfessional() {
  cloud1X += 0.8;
  if (cloud1X > width + 150) cloud1X = -150;
  cloud2X += 0.6;
  if (cloud2X > width + 150) cloud2X = -150;
  cloud3X += 0.4;
  if (cloud3X > width + 150) cloud3X = -150;
  drawCloudSoft(cloud1X, 120, 1.1, 60);
  drawCloudSoft(cloud2X, 80, 0.9, 40);
  drawCloudSoft(cloud3X, 180, 1.3, 80);
}

void drawCloudSoft(float x, float y, float scale, float blur) {
  noStroke();
  for (int i = 0; i < 8; i++) {
    float ox = cos(TWO_PI * i / 8.0) * 30 * scale;
    float oy = sin(TWO_PI * i / 8.0) * 12 * scale;
    fill(255, 60);
    ellipse(x + ox, y + oy, 70 * scale + blur, 50 * scale + blur * 0.7);
  }
  fill(255, 200);
  ellipse(x, y, 80 * scale, 60 * scale);
  ellipse(x + 30 * scale, y + 10 * scale, 60 * scale, 50 * scale);
  ellipse(x - 30 * scale, y + 10 * scale, 60 * scale, 50 * scale);
}

void drawBirds() {
  for (int k = 0; k < 3; k++) {
    float baseX = (frameCount * 1.3 + k * 250) % (width + 120) - 60;
    float baseY = 90 + k * 38 + sin(frameCount * 0.02 + k) * 10;
    for (int i = 0; i < 3 + (k % 2); i++) {
      float x = baseX + i * 28 + sin(frameCount * 0.05 + i + k) * 7;
      float y = baseY + sin(frameCount * 0.1 + i * 0.7 + k) * 8;
      float angle = sin(frameCount * 0.25 + i + k) * 0.8;
      drawBirdShape(x, y, 1.5 - k * 0.22, angle);
    }
  }
}

void drawBirdShape(float x, float y, float s, float angle) {
  pushMatrix();
  translate(x, y);
  
  // Mengurangi sedikit rotasi agar tidak terlalu tegak
  rotate(angle * 0.6); 

  // Variabel untuk bentuk sayap yang lebih lembut
  float wingSpan = 20 * s; // Lebar sayap
  float bodyDepth = 4 * s;   // Kedalaman lekukan tubuh
  
  // Animasi kepakan yang lebih lambat dan santai
  float flap = sin(frameCount * 0.25 + x); // Frekuensi lebih rendah
  float flapUp = map(flap, -1, 1, -wingSpan * 0.1, -wingSpan * 0.5); // Gerakan ke atas
  float flapDown = map(flap, -1, 1, bodyDepth, bodyDepth * 2.5);  // Gerakan ke bawah

  // Titik-titik utama untuk kurva Bezier
  PVector start = new PVector(-wingSpan / 2, flapUp * 0.6); // Ujung sayap kiri
  PVector end = new PVector(wingSpan / 2, flapUp * 0.6);   // Ujung sayap kanan
  
  // Titik kontrol untuk membentuk lekukan
  PVector control1 = new PVector(-wingSpan * 0.4, flapUp); // Kontrol sayap kiri
  PVector control2 = new PVector(0, flapDown);            // Kontrol tengah (lekukan tubuh)
  PVector control3 = new PVector(wingSpan * 0.4, flapUp);  // Kontrol sayap kanan

  // Menggambar bentuk burung dengan satu garis kurva yang mengalir
  noFill();
  stroke(40, 40, 40, 200); // Warna lebih gelap untuk kontras yang baik dengan background putih
  strokeWeight(2.4 * s);
  strokeCap(ROUND);
  strokeJoin(ROUND); // Menjamin sambungan kurva yang halus
  
  beginShape();
    vertex(start.x, start.y);
    // Menggunakan dua kurva Bezier yang bertemu di tengah untuk menciptakan bentuk 'm' yang lembut
    bezierVertex(control1.x, control1.y, control2.x, control2.y, control2.x, control2.y);
    bezierVertex(control2.x, control2.y, control3.x, control3.y, end.x, end.y);
  endShape();
  
  popMatrix();
}

//bimo
void drawBimo(float x, float y, float s, boolean isBlinking) {
  // Shadow
  fill(0, 50);
  noStroke();
  ellipse(x, y + 100 * s, 60 * s, 18 * s);

  // Animasi Bobbing (naik-turun)
  float bobbing = sin(frameCount * 0.1 + x) * 5;
  y += bobbing;

  // Tubuh
  fill(70, 130, 200); // Warna Bimo (Biru)
  stroke(40, 80, 120);
  strokeWeight(2.5 * s);
  rect(x - 25 * s, y + 40 * s, 50 * s, 60 * s, 20 * s);
  
  // Kepala
  fill(255, 220, 180);
  stroke(200, 170, 120);
  ellipse(x, y, 80 * s, 90 * s);
  
  // Rambut
  fill(60, 40, 20);
  noStroke();
  arc(x, y - 20 * s, 82 * s, 70 * s, PI, TWO_PI);
  
  // Mata
  if (isBlinking) {
    stroke(80, 60, 60);
    strokeWeight(2 * s);
    line(x - 22*s, y - 5*s, x - 14*s, y - 5*s); // Mata kiri tertutup
    line(x + 14*s, y - 5*s, x + 22*s, y - 5*s); // Mata kanan tertutup
  } else {
    noStroke();
    fill(20);
    ellipse(x - 18 * s, y - 5 * s, 10 * s, 12 * s);
    ellipse(x + 18 * s, y - 5 * s, 10 * s, 12 * s);
  }
  
  // Mulut
  noFill();
  stroke(180, 80, 80);
  strokeWeight(3 * s);
  arc(x, y + 15 * s, 30 * s, 18 * s, 0.1, PI - 0.1);
  
  // Tangan melambai
  float wave = radians(20) + sin(frameCount * 0.25 + x) * radians(30);
  pushMatrix();
  translate(x - 25 * s, y + 60 * s);
  rotate(-wave);
  fill(255, 220, 180);
  stroke(200, 170, 120);
  strokeWeight(1.5 * s);
  ellipse(0, 0, 20 * s, 20 * s);
  popMatrix();
  
  // Tangan diam
  ellipse(x + 35 * s, y + 60 * s, 20 * s, 20 * s);
}

// ==================== KARAKTER RARA (PEREMPUAN) ====================
void drawRara(float x, float y, float s, boolean isBlinking) {
  // Shadow
  fill(0, 50);
  noStroke();
  ellipse(x, y + 100 * s, 56 * s, 18 * s);

  // Animasi Bobbing (naik-turun)
  float bobbing = cos(frameCount * 0.1 + x) * 5; // Cosine agar gerak beda
  y += bobbing;

  // Tubuh
  fill(230, 100, 160); // Warna Rara (Pink)
  stroke(160, 60, 120);
  strokeWeight(2.5 * s);
  rect(x - 25 * s, y + 40 * s, 50 * s, 60 * s, 20 * s);
  endShape(CLOSE);
  
  // Kepala
  fill(255, 230, 200); // Warna kulit sedikit beda
  stroke(210, 180, 140);
  ellipse(x, y, 76 * s, 86 * s);
  
  // Rambut
  fill(80, 50, 30);
  noStroke();
  arc(x, y - 18*s, 78*s, 80*s, PI, TWO_PI);
  // Kuncir rambut
  fill(255, 220, 80); // Ikat rambut kuning
  ellipse(x - 35*s, y - 10*s, 15*s, 15*s);
  ellipse(x + 35*s, y - 10*s, 15*s, 15*s);

  // Mata
  if (isBlinking) {
    stroke(80, 60, 60);
    strokeWeight(1.8 * s);
    // Bulu mata lentik saat berkedip
    arc(x - 18*s, y - 5*s, 12*s, 8*s, 0, PI);
    arc(x + 18*s, y - 5*s, 12*s, 8*s, 0, PI);
  } else {
    noStroke();
    fill(20);
    ellipse(x - 16 * s, y - 4 * s, 10 * s, 14 * s); // Mata lebih oval
    ellipse(x + 16 * s, y - 4 * s, 10 * s, 14 * s);
    // Bulu mata
    stroke(20); strokeWeight(1.5*s);
    line(x+21*s, y-11*s, x+24*s, y-14*s);
  }
  
  // Mulut
  noFill();
  stroke(180, 80, 80);
  strokeWeight(2.5 * s);
  arc(x, y + 18 * s, 20 * s, 12 * s, 0.2, PI - 0.2); // Senyum
  
  // Tangan melambai
  float wave = radians(20) + cos(frameCount * 0.25 + x) * radians(30);
  pushMatrix();
  translate(x + 25*s, y + 60*s);
  rotate(wave);
  fill(255, 230, 200);
  stroke(210, 180, 140);
  strokeWeight(1.5*s);
  ellipse(0, 0, 18*s, 18*s);
  popMatrix();
  
  // Tangan diam
  ellipse(x - 32*s, y + 60*s, 18*s, 18*s);
}


//// Menggabungkan drawBimo dan drawRara menjadi satu fungsi generik
//void drawCharactersProfessional(float x, float y, float s) {
//  // Shadow
//  fill(0, 50);
//  noStroke();
//  ellipse(x, y + 100 * s, 60 * s, 18 * s);

//  // Animasi Bobbing (naik-turun)
//  float bobbing = sin(frameCount * 0.1 + x) * 5;
//  y += bobbing;

//  // Tubuh
//  fill(70, 130, 200); // Warna Bimo
//  stroke(40, 80, 120);
//  strokeWeight(2.5 * s);
//  rect(x - 25 * s, y + 40 * s, 50 * s, 60 * s, 20 * s);
  
//  // Kepala
//  fill(255, 220, 180);
//  stroke(200, 170, 120);
//  ellipse(x, y, 80 * s, 90 * s);
  
//  // Rambut
//  fill(60, 40, 20);
//  noStroke();
//  arc(x, y - 20 * s, 82 * s, 70 * s, PI, TWO_PI);
  
//  // Mata
//  fill(20);
//  ellipse(x - 18 * s, y - 5 * s, 10 * s, 12 * s);
//  ellipse(x + 18 * s, y - 5 * s, 10 * s, 12 * s);
  
//  // Mulut
//  noFill();
//  stroke(180, 80, 80);
//  strokeWeight(3 * s);
//  arc(x, y + 15 * s, 30 * s, 18 * s, 0.1, PI - 0.1);
  
//  // Tangan melambai
//  float wave = radians(20) + sin(frameCount * 0.25 + x) * radians(30);
//  pushMatrix();
//  translate(x - 25 * s, y + 60 * s);
//  rotate(-wave);
//  fill(255, 220, 180);
//  stroke(200, 170, 120);
//  strokeWeight(1.5 * s);
//  ellipse(0, 0, 20 * s, 20 * s);
//  popMatrix();
  
//  // Tangan diam
//  ellipse(x + 35 * s, y + 60 * s, 20 * s, 20 * s);
//}

void drawTextsOpening() {
  if (titleAlpha < 255) titleAlpha = min(255, titleAlpha + 3);
  if (titleAlpha > 200 && subAlpha < 255) subAlpha = min(255, subAlpha + 4);

  textAlign(CENTER, CENTER);
  
  // Judul
  textFont(fontTitle);
  fill(0, titleAlpha * 0.5);
  text("Jelajahi Warisan Nusantara", width / 2 + 3, 110 + 3);
  fill(255, 255, 220, titleAlpha);
  text("Jelajahi Warisan Nusantara", width / 2, 110);

  // Subjudul
  textFont(fontSub);
  fill(0, subAlpha * 0.5);
  text("bersama Bimo & Rara", width / 2 + 2, 170 + 2);
  fill(255, subAlpha);
  text("bersama Bimo & Rara", width / 2, 170);
}

void stop() {
  if (player != null) player.close();
  if (backsound != null) backsound.close();
  if (minim != null) minim.stop();
  super.stop();
}
