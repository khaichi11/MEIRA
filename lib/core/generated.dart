// DIHASILKAN OTOMATIS oleh scripts/export_dart.py. Jangan diedit manual.
// ignore_for_file: lines_longer_than_80_chars
library;

class IngredientRow {
  const IngredientRow(this.key, this.nameId, this.nameEn, this.category, this.synonyms, this.pantry);
  final String key;
  final String nameId;
  final String nameEn;
  final String category;
  final List<String> synonyms;
  final bool pantry;
}

const ingredientRows = <IngredientRow>[
  IngredientRow("apple", "apel", "apple", "buah", ["apel merah", "apel hijau", "apples"], false),
  IngredientRow("banana", "pisang", "banana", "buah", ["pisang ambon", "pisang kepok", "bananas"], false),
  IngredientRow("orange", "jeruk", "orange", "buah", ["jeruk manis", "jeruk peras", "oranges"], false),
  IngredientRow("lemon", "lemon", "lemon", "buah", ["jeruk lemon", "lemons"], false),
  IngredientRow("grape", "anggur", "grape", "buah", ["buah anggur", "grapes"], false),
  IngredientRow("strawberry", "stroberi", "strawberry", "buah", ["strawberry", "strawberries", "arbei"], false),
  IngredientRow("pear", "pir", "pear", "buah", ["buah pir", "pears"], false),
  IngredientRow("peach", "persik", "peach", "buah", ["buah persik", "peaches"], false),
  IngredientRow("pineapple", "nanas", "pineapple", "buah", ["nenas", "pineapples"], false),
  IngredientRow("watermelon", "semangka", "watermelon", "buah", ["watermelons"], false),
  IngredientRow("mango", "mangga", "mango", "buah", ["mangoes", "mangos"], false),
  IngredientRow("pomegranate", "delima", "pomegranate", "buah", ["buah delima", "pomegranates"], false),
  IngredientRow("grapefruit", "jeruk bali", "grapefruit", "buah", ["pomelo"], false),
  IngredientRow("cantaloupe", "melon", "cantaloupe", "buah", ["blewah", "melon jingga", "muskmelon"], false),
  IngredientRow("coconut", "kelapa", "coconut", "buah", ["kelapa muda", "coconuts"], false),
  IngredientRow("fig", "buah tin", "fig", "buah", ["ara", "figs", "common fig"], false),
  IngredientRow("tomato", "tomat", "tomato", "sayur", ["tomat merah", "tomatoes", "cherry tomato"], false),
  IngredientRow("carrot", "wortel", "carrot", "sayur", ["carrots"], false),
  IngredientRow("broccoli", "brokoli", "broccoli", "sayur", ["brocoli"], false),
  IngredientRow("cauliflower", "kembang kol", "cauliflower", "sayur", ["kembang kol putih"], false),
  IngredientRow("cabbage", "kol", "cabbage", "sayur", ["kubis", "kol putih", "kol ungu", "red cabbage"], false),
  IngredientRow("potato", "kentang", "potato", "sayur", ["potatoes"], false),
  IngredientRow("cucumber", "mentimun", "cucumber", "sayur", ["timun", "ketimun", "cucumbers"], false),
  IngredientRow("bell_pepper", "paprika", "bell pepper", "sayur", ["paprika merah", "paprika hijau", "capsicum", "bell peppers"], false),
  IngredientRow("zucchini", "zukini", "zucchini", "sayur", ["courgette"], false),
  IngredientRow("pumpkin", "labu kuning", "pumpkin", "sayur", ["waluh", "labu parang", "pumpkins"], false),
  IngredientRow("squash", "labu", "squash", "sayur", ["labu siam", "butternut"], false),
  IngredientRow("winter_melon", "kundur", "winter melon", "sayur", ["beligu", "labu air"], false),
  IngredientRow("radish", "lobak", "radish", "sayur", ["lobak putih", "daikon", "radishes"], false),
  IngredientRow("mushroom", "jamur", "mushroom", "sayur", ["jamur kancing", "jamur tiram", "jamur merang", "mushrooms"], false),
  IngredientRow("asparagus", "asparagus", "asparagus", "sayur", ["garden asparagus"], false),
  IngredientRow("artichoke", "artichoke", "artichoke", "sayur", ["artisyok"], false),
  IngredientRow("egg", "telur", "egg", "protein", ["telur ayam", "telor", "eggs"], false),
  IngredientRow("bread", "roti", "bread", "karbo", ["roti tawar", "roti gandum", "baguette"], false),
  IngredientRow("cheese", "keju", "cheese", "susu", ["keju cheddar", "keju parut"], false),
  IngredientRow("milk", "susu", "milk", "susu", ["susu cair", "susu segar", "susu uht", "frisian flag", "indomilk", "ultra milk"], false),
  IngredientRow("pasta", "pasta", "pasta", "karbo", ["spaghetti", "spageti", "makaroni", "fusilli", "penne"], false),
  IngredientRow("shrimp", "udang", "shrimp", "protein", ["udang segar", "prawn", "prawns"], false),
  IngredientRow("crab", "kepiting", "crab", "protein", ["rajungan", "crabs"], false),
  IngredientRow("rice", "nasi", "rice", "karbo", ["nasi putih", "beras", "nasi dingin"], false),
  IngredientRow("noodle", "mi", "noodle", "karbo", ["mie", "mie instan", "mi instan", "mi telur", "noodles", "ramen", "mi instan", "indomie", "mie sedaap", "sarimi", "supermi", "pop mie"], false),
  IngredientRow("tempeh", "tempe", "tempeh", "protein", ["tempe kedelai"], false),
  IngredientRow("tofu", "tahu", "tofu", "protein", ["tahu putih", "tahu kuning", "tahu sutra"], false),
  IngredientRow("chicken", "daging ayam", "chicken meat", "protein", ["ayam", "ayam potong", "dada ayam", "paha ayam", "chicken"], false),
  IngredientRow("beef", "daging sapi", "beef", "protein", ["daging", "daging giling", "beef"], false),
  IngredientRow("fish", "ikan", "fish", "protein", ["ikan segar", "fillet ikan", "ikan kembung", "ikan tongkol", "sarden", "ikan kaleng"], false),
  IngredientRow("sausage", "sosis", "sausage", "protein", ["sosis ayam", "sosis sapi", "sausages"], false),
  IngredientRow("meatball", "bakso", "meatball", "protein", ["pentol", "meatballs"], false),
  IngredientRow("chili", "cabai", "chili", "bumbu", ["cabe", "cabai rawit", "cabai merah", "cabe rawit", "chili pepper", "chilli"], false),
  IngredientRow("shallot", "bawang merah", "shallot", "bumbu", ["brambang", "shallots", "red onion"], false),
  IngredientRow("garlic", "bawang putih", "garlic", "bumbu", ["garlics"], false),
  IngredientRow("onion", "bawang bombay", "onion", "bumbu", ["bombay", "onions"], false),
  IngredientRow("spring_onion", "daun bawang", "spring onion", "sayur", ["bawang daun", "scallion", "green onion"], false),
  IngredientRow("celery", "seledri", "celery", "sayur", ["daun seledri"], false),
  IngredientRow("water_spinach", "kangkung", "water spinach", "sayur", ["kangkong"], false),
  IngredientRow("spinach", "bayam", "spinach", "sayur", ["bayam hijau"], false),
  IngredientRow("mustard_greens", "sawi", "mustard greens", "sayur", ["sawi hijau", "caisim", "pakcoy", "bok choy"], false),
  IngredientRow("long_bean", "kacang panjang", "long bean", "sayur", ["long beans"], false),
  IngredientRow("green_bean", "buncis", "green bean", "sayur", ["green beans"], false),
  IngredientRow("bean_sprout", "tauge", "bean sprout", "sayur", ["toge", "kecambah"], false),
  IngredientRow("corn", "jagung", "corn", "sayur", ["jagung manis", "sweet corn"], false),
  IngredientRow("eggplant", "terong", "eggplant", "sayur", ["terung", "aubergine"], false),
  IngredientRow("lettuce", "selada", "lettuce", "sayur", ["daun selada"], false),
  IngredientRow("lime", "jeruk nipis", "lime", "buah", ["jeruk limau", "limes"], false),
  IngredientRow("avocado", "alpukat", "avocado", "buah", ["avokad", "avocados"], false),
  IngredientRow("papaya", "pepaya", "papaya", "buah", ["kates"], false),
  IngredientRow("sweet_potato", "ubi", "sweet potato", "karbo", ["ubi jalar", "ubi ungu"], false),
  IngredientRow("cassava", "singkong", "cassava", "karbo", ["ubi kayu"], false),
  IngredientRow("peanut", "kacang tanah", "peanut", "protein", ["kacang", "peanuts", "selai kacang"], false),
  IngredientRow("mung_bean", "kacang hijau", "mung bean", "protein", ["kacang ijo", "mung beans"], false),
  IngredientRow("ginger", "jahe", "ginger", "bumbu", [], false),
  IngredientRow("lemongrass", "serai", "lemongrass", "bumbu", ["sereh"], false),
  IngredientRow("coconut_milk", "santan", "coconut milk", "susu", ["santan kental", "santan kara", "kara", "sasa santan", "santan kemasan"], false),
  IngredientRow("sweet_soy_sauce", "kecap manis", "sweet soy sauce", "bumbu", ["kecap", "kecap bango", "kecap abc", "kecap sedaap"], false),
  IngredientRow("oyster_sauce", "saus tiram", "oyster sauce", "bumbu", [], false),
  IngredientRow("butter", "mentega", "butter", "susu", ["margarin", "butter", "blue band"], false),
  IngredientRow("yogurt", "yoghurt", "yogurt", "susu", ["yogurt", "yoghurt plain"], false),
  IngredientRow("honey", "madu", "honey", "bumbu", [], false),
  IngredientRow("vinegar", "cuka", "vinegar", "bumbu", ["cuka makan", "cuka apel"], false),
  IngredientRow("bay_leaf", "daun salam", "bay leaf", "bumbu", ["salam"], false),
  IngredientRow("candlenut", "kemiri", "candlenut", "bumbu", ["kemiri sangrai"], false),
  IngredientRow("cinnamon", "kayu manis", "cinnamon", "bumbu", ["kulit kayu manis", "cinnamon stick"], false),
  IngredientRow("turmeric", "kunyit", "turmeric", "bumbu", ["kunyit bubuk", "temu kuning"], false),
  IngredientRow("mint", "daun mint", "mint", "sayur", ["mint segar", "pudina"], false),
  IngredientRow("oats", "oat", "oats", "karbo", ["oatmeal", "havermut"], false),
  IngredientRow("flour", "tepung terigu", "flour", "karbo", ["tepung", "terigu", "segitiga biru", "cakra kembar"], false),
  IngredientRow("chocolate", "cokelat", "chocolate", "camilan", ["coklat", "meses", "chocolate"], false),
  IngredientRow("palm_sugar", "gula merah", "palm sugar", "bumbu", ["gula jawa", "gula aren"], false),
  IngredientRow("ice", "es batu", "ice", "lainnya", ["es"], false),
  IngredientRow("salt", "garam", "salt", "bumbu", [], true),
  IngredientRow("sugar", "gula", "sugar", "bumbu", ["gula pasir", "gulaku"], true),
  IngredientRow("cooking_oil", "minyak goreng", "cooking oil", "bumbu", ["minyak", "bimoli", "filma", "sania", "minyak sayur", "minyak kelapa sawit"], true),
  IngredientRow("pepper", "merica", "pepper", "bumbu", ["lada", "merica bubuk"], true),
  IngredientRow("water", "air", "water", "lainnya", ["air matang"], true),
];

const unitTable = <String, (String, String)>{"grape": ("tandan", "beberapa tandan"), "banana": ("buah", "sisir"), "egg": ("butir", "setumpuk"), "garlic": ("siung", "bonggol"), "shallot": ("siung", "setumpuk"), "spring_onion": ("batang", "ikat"), "celery": ("batang", "ikat"), "lemongrass": ("batang", "ikat"), "water_spinach": ("ikat", "beberapa ikat"), "spinach": ("ikat", "beberapa ikat"), "mustard_greens": ("ikat", "beberapa ikat"), "long_bean": ("ikat", "beberapa ikat"), "green_bean": ("ikat", "beberapa ikat"), "lettuce": ("ikat", "beberapa ikat"), "asparagus": ("batang", "ikat"), "broccoli": ("bonggol", "setumpuk"), "cabbage": ("buah", "setumpuk"), "corn": ("tongkol", "setumpuk"), "shrimp": ("ekor", "setumpuk"), "crab": ("ekor", "setumpuk"), "fish": ("ekor", "setumpuk"), "tofu": ("potong", "setumpuk"), "tempeh": ("papan", "setumpuk"), "chili": ("buah", "segenggam"), "strawberry": ("buah", "segenggam"), "mushroom": ("buah", "segenggam")};
const massKeys = <String>{"bean_sprout", "beef", "bread", "butter", "cheese", "chicken", "chocolate", "coconut_milk", "cooking_oil", "flour", "honey", "ice", "meatball", "milk", "mung_bean", "noodle", "oats", "oyster_sauce", "palm_sugar", "pasta", "peanut", "pepper", "rice", "salt", "sugar", "sweet_soy_sauce", "water", "yogurt"};

const promptGround = "Tandai setiap bahan makanan di foto, satu baris untuk setiap buah atau bahan: nama x1 y1 x2 y2 (skala 0-1000). Beri * setelah nama untuk tumpukan yang tidak bisa dipisah. Urutkan dari kiri ke kanan.";
const promptVerify = "Apakah ada {name} di foto ini? Jawab \"tidak ada\", atau \"ada\" lalu satu baris x1 y1 x2 y2 (skala 0-1000) untuk setiap {name} yang terlihat.";
const promptGroundZeroshot = "Deteksi setiap bahan makanan di foto, satu kotak untuk setiap buah atau bahan. Jawab hanya JSON: daftar objek berisi \"bbox_2d\" [x1, y1, x2, y2] skala 0-1000 dan \"label\" nama bahan dalam bahasa Indonesia.";
const promptVerifyZeroshot = "Apakah ada {name} di foto ini? Jawab hanya JSON berisi \"ada\" (true/false) dan \"bbox_2d\" berupa daftar kotak [x1, y1, x2, y2] skala 0-1000 untuk setiap {name} yang terlihat.";
const promptScene = "Lihat foto ini. Apakah isinya bahan makanan yang belum dimasak, atau makanan jadi (hidangan siap makan)? Jawab hanya JSON berisi \"jenis\" (\"bahan\" atau \"hidangan\"), \"hidangan\" (nama hidangan dalam bahasa Indonesia, atau null bila jenisnya bahan), dan \"bahan_utama\" (daftar bahan yang kemungkinan dipakai, maksimal 8).";
const promptBrainSystem = "Anda adalah MEIRA, asisten dapur yang berjalan sepenuhnya di perangkat pengguna tanpa internet.\nGaya bahasa: sopan, formal, hangat, dan mengalir seperti juru masak berpengalaman yang menjelaskan kepada tamu. Sapa pengguna dengan \"Anda\".\nAturan:\n- Jawab langsung sejak kalimat pertama. Jangan mengulang pertanyaan pengguna dan jangan memperkenalkan diri.\n- Anggap sebuah bahan \"ada\" hanya bila tercantum di DAFTAR BAHAN DI FOTO, dan sebut nomornya, misalnya \"pisang (#1)\".\n- Bahan resep yang tidak terlihat disebut terus terang sebagai bahan yang perlu disiapkan.\n- Bumbu dasar (garam, gula, minyak, merica, air) boleh dianggap tersedia, tetapi tetap disebutkan.\n- Gunakan resep dari KANDIDAT RESEP dan fakta dari PENGETAHUAN DAPUR; jangan mengarang fakta atau resep lain.\n- Saat menjelaskan sebuah istilah atau teknik, jelaskan wujud, cara, dan bedanya secara konkret. Jangan mendefinisikan istilah dengan istilah itu sendiri.\n- Untuk foto makanan jadi, bedakan bahan yang TERLIHAT (bernomor) dari bahan yang hanya perkiraan.\n- Jangan menyebut nama bagian konteks (RESEP TERPILIH, KANDIDAT LAIN, TUGAS); berbicaralah langsung kepada pengguna.\n- Jawaban akan dibacakan: paling banyak 6 kalimat atau langkah singkat bernomor, tanpa tabel, tanpa emoji, tanpa tanda pisah panjang.\n";
const promptIntentSystem = "Ubah permintaan pengguna aplikasi resep menjadi JSON. Isi hanya yang disebut pengguna.\nKunci:\n- action: \"rekomendasi\" (minta ide/resep), \"hidangan\" (tanya ini makanan apa / bahannya apa saja), \"ganti\" (minta resep lain/alternatif), \"pilih\" (memilih resep tertentu),\n  \"detail\" (minta langkah/cara/bahan resep saat ini), \"substitusi\" (tanya pengganti bahan), \"cek\" (tanya apakah bahan ada di foto),\n  \"obrolan\" (lainnya)\n- max_minutes: batas waktu masak dalam menit (angka) bila disebut, misal \"cepat\" = 15\n- tags: daftar dari [sarapan, camilan, minuman, berkuah, pedas, manis, segar, sehat, vegetarian, anak, tanpa-kompor, hemat]\n- exclude: bahan yang tidak mau dipakai/tidak suka\n- include: bahan yang ingin dipakai\n- ingredient: bahan yang ditanyakan (untuk cek/substitusi)\n- choice: nomor pilihan resep (1, 2, 3) atau nama resep bila memilih\nContoh: \"yang lain dong, jangan pedas, aku cuma punya 10 menit\" ->\n{\"action\":\"ganti\",\"max_minutes\":10,\"tags\":[],\"exclude\":[\"cabai\"],\"include\":[],\"ingredient\":null,\"choice\":null}";
const promptNoteTask = "Jawab pertanyaan secara langsung dalam 1 sampai 3 kalimat formal berdasarkan catatan di atas. Sebut angka, waktu, dan caranya persis seperti di catatan. Jangan menambahkan fakta yang tidak ada di catatan.";
const promptPersonalSystem = "Anda MEIRA, asisten dapur yang sopan dan hangat. Tulis tepat satu kalimat pendek dan formal (maksimal 15 kata) yang menanggapi permintaan pengguna tentang resep {recipe}. Jangan menyebut bahan, angka, waktu, atau langkah. Tanpa emoji.";
const sceneSchema = "{\"type\": \"object\", \"properties\": {\"jenis\": {\"type\": \"string\", \"enum\": [\"bahan\", \"hidangan\"]}, \"hidangan\": {\"type\": [\"string\", \"null\"]}, \"bahan_utama\": {\"type\": \"array\", \"items\": {\"type\": \"string\"}, \"maxItems\": 8}}, \"required\": [\"jenis\", \"hidangan\", \"bahan_utama\"]}";
const intentSchema = "{\"type\": \"object\", \"properties\": {\"action\": {\"type\": \"string\", \"enum\": [\"rekomendasi\", \"hidangan\", \"ganti\", \"pilih\", \"detail\", \"substitusi\", \"cek\", \"obrolan\"]}, \"max_minutes\": {\"type\": [\"integer\", \"null\"]}, \"tags\": {\"type\": \"array\", \"items\": {\"type\": \"string\"}}, \"exclude\": {\"type\": \"array\", \"items\": {\"type\": \"string\"}}, \"include\": {\"type\": \"array\", \"items\": {\"type\": \"string\"}}, \"ingredient\": {\"type\": [\"string\", \"null\"]}, \"choice\": {\"type\": [\"string\", \"integer\", \"null\"]}}, \"required\": [\"action\", \"max_minutes\", \"tags\", \"exclude\", \"include\", \"ingredient\", \"choice\"]}";
const promptPackages = "Baca tulisan pada kemasan makanan atau bumbu yang terlihat di foto (bungkus, botol, kaleng, kotak). Untuk setiap kemasan tulis merek atau tulisan utama yang terbaca, jenis produknya dalam bahasa Indonesia (misalnya mi instan, minyak goreng, kecap manis, santan, saus tiram, sarden, tepung terigu, gula, susu), dan kotak bbox_2d skala 0-1000. Jika tidak ada kemasan, kembalikan daftar kosong.";
const packagesSchema = "{\"type\": \"object\", \"properties\": {\"kemasan\": {\"type\": \"array\", \"maxItems\": 8, \"items\": {\"type\": \"object\", \"properties\": {\"tulisan\": {\"type\": \"string\"}, \"jenis\": {\"type\": \"string\"}, \"bbox_2d\": {\"type\": \"array\", \"items\": {\"type\": \"integer\"}, \"minItems\": 4, \"maxItems\": 4}}, \"required\": [\"tulisan\", \"jenis\", \"bbox_2d\"]}}}, \"required\": [\"kemasan\"]}";

/// Bahan yang bisa dikenali kamera dengan andal (hasil evaluasi). Bahan lain tidak dicap "kurang" bila tak terlihat.
const detectableKeys = <String>{"apple", "artichoke", "asparagus", "avocado", "banana", "beef", "bell_pepper", "bread", "broccoli", "butter", "cabbage", "cantaloupe", "carrot", "cauliflower", "celery", "cheese", "chili", "coconut", "corn", "crab", "cucumber", "egg", "eggplant", "fig", "garlic", "ginger", "grape", "grapefruit", "green_bean", "honey", "lemon", "lettuce", "lime", "mango", "meatball", "milk", "mushroom", "onion", "orange", "papaya", "pasta", "peach", "pear", "pineapple", "pomegranate", "potato", "pumpkin", "radish", "sausage", "shrimp", "spring_onion", "squash", "strawberry", "sweet_potato", "tofu", "tomato", "watermelon", "winter_melon", "yogurt", "zucchini"};
