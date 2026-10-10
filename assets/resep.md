# Buku Resep MEIRA

Ditulis untuk proyek MEIRA dan dilepas ke domain publik (CC0 1.0).
Format tiap resep:

    ## id | Nama | menit | porsi | kesulitan
    tag: ...            (sarapan, camilan, minuman, berkuah, pedas, manis, segar, sehat, vegetarian, anak, tanpa-kompor, hemat)
    desc: satu kalimat
    bahan:
    - kunci_bahan* | jumlah      (* = bahan utama, ? = opsional; kunci dari meira/vocab.py)
    langkah:
    1. ...
    tip: ...
    alat: wajan, spatula, ...
    ganti: kunci = saran pengganti; ...

## smoothie-pisang-susu | Smoothie Pisang Susu | 5 | 1 | mudah
tag: sarapan, minuman, manis, anak, tanpa-kompor, vegetarian
desc: Minuman kental pengganjal pagi yang hanya memerlukan blender.
bahan:
- banana* | 2 buah matang
- milk* | 250 ml
- honey? | 1 sdm
- oats? | 2 sdm
- ice? | 4 kotak
langkah:
1. Kupas pisang lalu potong-potong.
2. Masukkan pisang, susu, madu, dan oat ke blender.
3. Blender sampai halus, tambahkan es batu bila ingin dingin.
4. Sajikan segera.
tip: Pisang yang kulitnya mulai berbintik cokelat paling manis untuk smoothie.
alat: blender, pisau, talenan, gelas
ganti: milk = yoghurt encer atau susu kedelai; honey = gula pasir

## jus-mangga | Jus Mangga Segar | 5 | 2 | mudah
tag: minuman, segar, manis, tanpa-kompor, vegetarian
desc: Jus kental dari mangga matang tanpa perlu banyak gula.
bahan:
- mango* | 2 buah matang
- milk? | 100 ml
- water | 150 ml
- sugar? | 1 sdm
- ice? | secukupnya
langkah:
1. Kupas mangga dan ambil dagingnya.
2. Blender mangga dengan air, susu, dan gula sampai halus.
3. Tuang ke gelas berisi es batu.
tip: Cicipi dulu sebelum menambah gula; mangga harum manis biasanya sudah cukup manis.
alat: blender, pisau, talenan, gelas
ganti: milk = yoghurt

## es-buah-segar | Es Buah Segar | 10 | 4 | mudah
tag: minuman, segar, manis, tanpa-kompor, vegetarian
desc: Potongan buah dingin dalam kuah manis, cocok untuk siang hari.
bahan:
- watermelon* | 1/4 buah
- cantaloupe* | 1/4 buah
- pineapple? | 1/4 buah
- coconut? | 1 buah kelapa muda, kerok
- milk? | 100 ml susu kental manis atau susu cair
- sugar | 3 sdm, larutkan dengan sedikit air
- ice | secukupnya
langkah:
1. Potong dadu semangka, melon, dan nanas.
2. Campur buah dengan kerokan kelapa muda di mangkuk besar.
3. Tuang larutan gula dan susu, aduk rata.
4. Tambahkan es batu dan sajikan.
tip: Simpan buah di kulkas dulu supaya es tidak cepat mencair.
alat: pisau, talenan, mangkuk, sendok
ganti: cantaloupe = pepaya; watermelon = melon hijau

## rujak-buah | Rujak Buah Sambal Gula Merah | 15 | 3 | mudah
tag: camilan, segar, pedas, tanpa-kompor, vegetarian
desc: Buah renyah dengan sambal gula merah pedas manis.
bahan:
- pineapple* | 1/4 buah
- mango* | 1 buah mengkal
- cucumber* | 1 buah
- apple? | 1 buah
- palm_sugar | 75 g
- chili* | 3 buah cabai rawit
- peanut? | 2 sdm, sangrai
- salt | sejumput
langkah:
1. Potong semua buah memanjang.
2. Ulek cabai, garam, dan kacang tanah.
3. Tambahkan gula merah dan sedikit air, ulek sampai kental.
4. Sajikan buah dengan sambal di samping.
tip: Mangga yang masih agak muda memberi rasa asam yang pas untuk rujak.
alat: pisau, talenan, ulekan, mangkuk
ganti: palm_sugar = gula pasir dan sedikit kecap manis

## salad-buah-yoghurt | Salad Buah Yoghurt | 10 | 2 | mudah
tag: sarapan, segar, sehat, manis, anak, tanpa-kompor, vegetarian
desc: Buah potong dengan saus yoghurt madu, ringan tapi mengenyangkan.
bahan:
- apple* | 1 buah
- grape* | 1 genggam
- strawberry* | 6 buah
- pear? | 1 buah
- yogurt* | 150 g
- honey? | 1 sdm
- cheese? | 2 sdm, parut
langkah:
1. Potong apel dan pir dadu, belah anggur dan stroberi.
2. Campur yoghurt dengan madu.
3. Aduk buah dengan saus yoghurt, taburi keju parut bila suka.
4. Dinginkan sebentar lalu sajikan.
tip: Rendam potongan apel di air garam sebentar agar tidak cepat kecokelatan.
alat: pisau, talenan, mangkuk
ganti: yogurt = mayones dicampur susu kental manis; grape = melon

## es-jeruk-peras | Es Jeruk Peras | 5 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian, hemat
desc: Jeruk peras murni, segar dan kaya vitamin C.
bahan:
- orange* | 6 buah
- sugar? | 1 sdm
- water | 100 ml
- ice | secukupnya
langkah:
1. Belah jeruk dan peras airnya, saring bijinya.
2. Campur dengan air dan gula, aduk sampai larut.
3. Tuang ke gelas berisi es.
tip: Gulingkan jeruk di meja sambil ditekan sebelum dibelah agar airnya lebih banyak keluar.
alat: pisau, talenan, gelas, sendok
ganti: orange = jeruk bali atau lemon dengan tambahan gula

## lemon-madu-hangat | Lemon Madu Hangat | 5 | 1 | mudah
tag: minuman, sehat, vegetarian
desc: Minuman hangat penenang tenggorokan.
bahan:
- lemon* | 1/2 buah
- honey* | 1-2 sdm
- ginger? | 1 ruas, memarkan
- water | 250 ml air panas
langkah:
1. Seduh jahe dengan air panas selama 3 menit.
2. Peras lemon ke dalam gelas.
3. Tambahkan madu setelah air agak turun suhunya, aduk.
tip: Jangan masukkan madu ke air mendidih agar aromanya tidak hilang.
alat: panci kecil, gelas, pisau, talenan
ganti: lemon = jeruk nipis

## pisang-goreng | Pisang Goreng Tepung | 20 | 3 | mudah
tag: camilan, manis, anak, vegetarian, hemat
desc: Pisang berbalut adonan renyah, camilan sore klasik.
bahan:
- banana* | 4 buah, belah dua
- flour | 100 g
- sugar | 1 sdm
- salt | sejumput
- water | 120 ml
- cooking_oil | untuk menggoreng
langkah:
1. Campur tepung, gula, garam, dan air sampai adonan kental licin.
2. Panaskan minyak dengan api sedang.
3. Celup pisang ke adonan lalu goreng sampai kuning keemasan.
4. Tiriskan di atas tisu.
tip: Tambahkan satu sendok tepung beras ke adonan supaya lebih renyah.
alat: wajan, spatula, mangkuk, pisau
ganti: banana = nangka atau ubi

## pisang-bakar-cokelat-keju | Pisang Bakar Cokelat Keju | 15 | 2 | mudah
tag: camilan, manis, anak, vegetarian
desc: Pisang dipanggang di teflon dengan lelehan cokelat dan keju.
bahan:
- banana* | 3 buah
- chocolate | 2 sdm meses atau cokelat batang
- cheese* | 30 g, parut
- butter? | 1 sdm
langkah:
1. Belah pisang memanjang tanpa terputus.
2. Panaskan mentega di teflon, panggang pisang sampai kedua sisi kecokelatan.
3. Angkat, taburi cokelat dan keju parut selagi panas.
tip: Tekan pisang dengan spatula saat dipanggang agar lebih pipih dan matang merata.
alat: teflon, spatula, pisau, parutan
ganti: chocolate = susu kental manis cokelat; cheese = kacang cincang

## es-kelapa-muda | Es Kelapa Muda | 5 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Air dan daging kelapa muda yang menyegarkan.
bahan:
- coconut* | 1 buah kelapa muda
- palm_sugar? | 2 sdm sirup gula merah
- lime? | 1/2 buah
- ice | secukupnya
langkah:
1. Buka kelapa, tuang airnya ke wadah.
2. Kerok daging kelapa memanjang.
3. Campur air, daging kelapa, dan sirup gula merah.
4. Tambahkan perasan jeruk nipis dan es batu.
alat: sendok, gelas, pisau
ganti: palm_sugar = sirup cocopandan

## jus-semangka | Jus Semangka Jeruk Nipis | 5 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian, hemat
desc: Jus merah segar dengan sentuhan asam jeruk nipis.
bahan:
- watermelon* | 1/4 buah, buang bijinya
- lime? | 1/2 buah
- sugar? | 1 sdt
- ice | secukupnya
langkah:
1. Potong semangka dan buang bijinya.
2. Blender semangka tanpa air sampai halus.
3. Tambahkan perasan jeruk nipis dan gula, aduk.
4. Sajikan dengan es batu.
tip: Semangka sudah banyak mengandung air, jadi tidak perlu ditambah air.
alat: blender, pisau, talenan, gelas

## susu-stroberi | Susu Stroberi Blender | 5 | 1 | mudah
tag: minuman, manis, anak, tanpa-kompor, vegetarian
desc: Susu merah muda dari stroberi segar tanpa sirup buatan.
bahan:
- strawberry* | 8 buah
- milk* | 200 ml
- honey? | 1 sdm
- ice? | 3 kotak
langkah:
1. Cuci stroberi dan buang daunnya.
2. Blender stroberi, susu, dan madu sampai halus.
3. Tuang ke gelas, tambahkan es.
alat: blender, pisau, talenan, gelas
ganti: strawberry = pisang atau mangga

## jus-jeruk-wortel | Jus Jeruk Wortel | 10 | 2 | mudah
tag: minuman, sehat, segar, tanpa-kompor, vegetarian
desc: Perpaduan manis wortel dan asam jeruk, kaya vitamin.
bahan:
- orange* | 3 buah
- carrot* | 2 batang
- honey? | 1 sdm
- water | 100 ml
langkah:
1. Kupas dan potong wortel kecil-kecil.
2. Peras jeruk.
3. Blender wortel dengan air jeruk dan air sampai halus, saring bila suka.
4. Tambahkan madu dan sajikan dingin.
alat: blender, pisau, talenan, gelas, parutan

## jus-apel-pir | Jus Apel Pir | 5 | 2 | mudah
tag: minuman, segar, sehat, tanpa-kompor, vegetarian
desc: Jus ringan dengan rasa manis lembut.
bahan:
- apple* | 1 buah
- pear* | 1 buah
- lemon? | sedikit perasan
- water | 150 ml
- ice? | secukupnya
langkah:
1. Potong apel dan pir, buang bijinya.
2. Blender dengan air sampai halus.
3. Tambahkan perasan lemon agar warnanya tetap cerah.
alat: blender, pisau, talenan, gelas

## kolak-pisang-labu | Kolak Pisang Labu | 30 | 4 | sedang
tag: manis, berkuah, vegetarian
desc: Hidangan manis bersantan, hangat untuk berbuka atau sore hari.
bahan:
- banana* | 4 buah pisang kepok
- pumpkin* | 300 g
- coconut_milk | 400 ml
- palm_sugar | 100 g
- salt | sejumput
- water | 300 ml
langkah:
1. Potong labu dadu dan pisang serong.
2. Rebus air dengan gula merah sampai larut, saring.
3. Masukkan labu, masak sampai setengah empuk.
4. Tambahkan pisang, santan, dan garam; aduk terus sampai mendidih.
tip: Aduk santan terus agar tidak pecah.
alat: panci, sendok kayu, pisau, talenan
ganti: pumpkin = ubi; coconut_milk = susu cair untuk versi lebih ringan

## overnight-oats-pisang | Overnight Oats Pisang Stroberi | 5 | 1 | mudah
tag: sarapan, sehat, tanpa-kompor, vegetarian
desc: Siapkan malam hari, besok pagi tinggal makan.
bahan:
- oats | 5 sdm
- milk* | 150 ml
- banana* | 1 buah
- strawberry? | 4 buah
- honey? | 1 sdm
- yogurt? | 2 sdm
langkah:
1. Campur oat, susu, yoghurt, dan madu dalam wadah bertutup.
2. Tambahkan irisan pisang dan stroberi di atasnya.
3. Simpan di kulkas minimal 4 jam atau semalaman.
alat: toples, sendok, pisau
ganti: strawberry = mangga atau anggur

## telur-dadar-sayur | Telur Dadar Sayur | 10 | 2 | mudah
tag: sarapan, hemat, anak, vegetarian
desc: Telur dadar tebal berisi sayuran cincang.
bahan:
- egg* | 3 butir
- carrot? | 1/2 batang, parut
- cabbage? | 1 lembar, iris halus
- spring_onion? | 1 batang
- salt | 1/4 sdt
- pepper | sejumput
- cooking_oil | 1 sdm
langkah:
1. Kocok telur dengan garam dan merica.
2. Masukkan wortel, kol, dan daun bawang, aduk.
3. Panaskan minyak, tuang adonan, masak dengan api kecil sampai bagian bawah set.
4. Balik dan masak sebentar sampai matang.
tip: Api kecil membuat telur dadar tebal matang sampai tengah tanpa gosong.
alat: wajan, spatula, mangkuk, garpu

## orak-arik-telur-tomat | Orak-arik Telur Tomat | 10 | 2 | mudah
tag: sarapan, hemat, vegetarian
desc: Telur lembut dengan tomat asam manis, cepat dan cocok dengan nasi.
bahan:
- egg* | 3 butir
- tomato* | 2 buah
- spring_onion? | 1 batang
- garlic | 2 siung
- sugar | 1/2 sdt
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Kocok telur dengan sedikit garam, orak-arik setengah matang lalu angkat.
2. Tumis bawang putih sampai harum, masukkan potongan tomat.
3. Masak tomat sampai layu dan berair, beri gula dan garam.
4. Masukkan kembali telur, aduk sebentar, taburi daun bawang.
tip: Jangan masak telur terlalu lama di langkah pertama supaya tetap lembut.
alat: wajan, spatula, mangkuk, pisau

## telur-ceplok-kecap | Telur Ceplok Kecap | 10 | 2 | mudah
tag: hemat, anak, vegetarian
desc: Telur mata sapi bersiram kecap manis gurih.
bahan:
- egg* | 3 butir
- sweet_soy_sauce | 2 sdm
- shallot | 3 siung, iris
- chili? | 2 buah, iris
- cooking_oil | 2 sdm
langkah:
1. Goreng telur ceplok satu per satu, sisihkan.
2. Tumis bawang merah dan cabai sampai harum.
3. Tambahkan kecap dan sedikit air, masak sebentar.
4. Masukkan telur, siram dengan kuah kecap sampai rata.
alat: teflon, spatula, piring

## roti-panggang-keju | Roti Panggang Keju | 10 | 2 | mudah
tag: sarapan, anak, vegetarian
desc: Roti renyah dengan keju meleleh, dipanggang di teflon.
bahan:
- bread* | 4 lembar
- cheese* | 4 lembar atau 60 g parut
- butter? | 1 sdm
langkah:
1. Oles salah satu sisi roti dengan mentega.
2. Letakkan keju di antara dua roti, sisi bermentega di luar.
3. Panggang di teflon api kecil sampai kecokelatan dan keju meleleh.
alat: teflon, spatula, parutan
ganti: butter = sedikit minyak; cheese = selai kacang

## roti-celup-telur | Roti Celup Telur Susu (French Toast) | 15 | 2 | mudah
tag: sarapan, manis, anak, vegetarian
desc: Roti dicelup campuran telur susu lalu dipanggang sampai keemasan.
bahan:
- bread* | 4 lembar
- egg* | 2 butir
- milk* | 100 ml
- sugar | 1 sdm
- butter? | 1 sdm
- banana? | 1 buah untuk topping
- strawberry? | beberapa buah untuk topping
langkah:
1. Kocok telur, susu, dan gula.
2. Celup roti bolak-balik ke campuran telur.
3. Panggang di teflon bermentega sampai kedua sisi kecokelatan.
4. Sajikan dengan irisan pisang atau stroberi.
alat: teflon, spatula, mangkuk, garpu

## sandwich-telur | Sandwich Telur | 15 | 2 | mudah
tag: sarapan, anak, vegetarian
desc: Roti isi telur rebus tumbuk dengan sayur segar.
bahan:
- bread* | 4 lembar
- egg* | 3 butir
- lettuce? | 2 lembar
- tomato? | 1 buah
- cucumber? | 1/2 buah
- cheese? | 2 lembar
- salt | sejumput
- pepper | sejumput
langkah:
1. Rebus telur 10 menit, kupas dan tumbuk kasar dengan garam dan merica.
2. Iris tipis tomat dan mentimun.
3. Susun selada, telur, sayuran, dan keju di atas roti.
4. Tutup dengan roti lain dan potong diagonal.
tip: Tambahkan sedikit mayones atau yoghurt ke telur tumbuk agar lebih lembut.
alat: panci, mangkuk, pisau, talenan

## sandwich-sayur-keju | Sandwich Sayur Keju Tanpa Masak | 5 | 1 | mudah
tag: sarapan, segar, tanpa-kompor, vegetarian
desc: Roti isi sayur segar dan keju, tidak perlu kompor sama sekali.
bahan:
- bread* | 2 lembar
- cheese* | 2 lembar
- tomato* | 1 buah
- cucumber* | 1/2 buah
- lettuce? | 1 lembar
- pepper | sejumput
langkah:
1. Iris tipis tomat dan mentimun.
2. Susun keju, selada, tomat, dan mentimun di atas roti.
3. Taburi merica, tutup dengan roti, lalu potong.
alat: pisau, talenan, piring

## salad-telur-kentang | Salad Kentang Telur | 25 | 3 | mudah
tag: sarapan, vegetarian
desc: Kentang rebus dan telur dengan saus yoghurt, mengenyangkan.
bahan:
- potato* | 3 buah
- egg* | 2 butir
- carrot? | 1 batang
- cucumber? | 1/2 buah
- yogurt? | 3 sdm
- salt | secukupnya
- pepper | secukupnya
langkah:
1. Rebus kentang dan wortel yang sudah dipotong dadu sampai empuk.
2. Rebus telur 10 menit, kupas dan potong.
3. Campur semua bahan dengan yoghurt, garam, dan merica.
4. Dinginkan sebelum disajikan.
alat: panci, mangkuk, pisau, talenan
ganti: yogurt = mayones

## omelet-jamur-keju | Omelet Jamur Keju | 15 | 1 | mudah
tag: sarapan, vegetarian
desc: Omelet lembut berisi tumisan jamur dan keju leleh.
bahan:
- egg* | 3 butir
- mushroom* | 100 g
- cheese* | 30 g
- milk? | 2 sdm
- butter? | 1 sdm
- salt | secukupnya
- pepper | secukupnya
langkah:
1. Iris jamur dan tumis dengan mentega sampai layu, sisihkan.
2. Kocok telur, susu, garam, dan merica.
3. Tuang telur ke teflon, masak api kecil.
4. Saat permukaan hampir set, isi dengan jamur dan keju, lipat dua.
alat: teflon, spatula, mangkuk, pisau

## telur-masak-tomat-paprika | Telur Masak Tomat Paprika (Shakshuka) | 20 | 2 | sedang
tag: sarapan, pedas, vegetarian
desc: Telur dimasak langsung di atas saus tomat paprika yang kental.
bahan:
- egg* | 3 butir
- tomato* | 4 buah
- bell_pepper* | 1 buah
- onion | 1/2 buah
- garlic | 2 siung
- chili? | 1 buah
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Tumis bawang bombay, bawang putih, dan paprika sampai layu.
2. Masukkan tomat cincang dan cabai, masak sampai mengental.
3. Buat lubang di saus, pecahkan telur di tiap lubang.
4. Tutup wajan, masak 5-7 menit sampai putih telur matang.
tip: Sajikan dengan roti untuk mencocol sausnya.
alat: wajan, spatula, pisau, talenan

## sayur-sop | Sayur Sop Rumahan | 30 | 4 | mudah
tag: berkuah, sehat, anak, hemat
desc: Sup bening hangat penuh sayur, cocok untuk semua umur.
bahan:
- carrot* | 2 batang
- potato* | 2 buah
- cabbage* | 1/4 buah
- spring_onion? | 1 batang
- celery? | 1 batang
- chicken? | 200 g atau ganti bakso
- garlic | 3 siung
- shallot | 3 siung
- salt | secukupnya
- pepper | 1/2 sdt
- water | 1,2 liter
langkah:
1. Rebus ayam atau bakso dalam air sampai keluar kaldu.
2. Tumis bawang merah dan bawang putih, masukkan ke kuah.
3. Masukkan kentang dan wortel, masak sampai setengah empuk.
4. Tambahkan kol, daun bawang, dan seledri, bumbui garam dan merica.
tip: Masukkan sayur dari yang paling keras agar semua matang bersamaan.
alat: panci, sendok sayur, pisau, talenan
ganti: chicken = bakso, sosis, atau tanpa daging; cabbage = sawi

## tumis-brokoli-wortel | Tumis Brokoli Wortel | 15 | 3 | mudah
tag: sehat, vegetarian
desc: Tumisan sayur renyah dengan bawang putih dan saus tiram.
bahan:
- broccoli* | 1 bonggol
- carrot* | 1 batang
- garlic | 3 siung
- oyster_sauce? | 1 sdm
- salt | secukupnya
- water | 50 ml
- cooking_oil | 1 sdm
langkah:
1. Potong brokoli per kuntum, iris serong wortel.
2. Tumis bawang putih sampai harum.
3. Masukkan wortel dulu, lalu brokoli dan air.
4. Bumbui saus tiram dan garam, masak sebentar agar tetap renyah.
alat: wajan, spatula, pisau, talenan
ganti: broccoli = buncis atau kembang kol

## capcay-kuah | Capcay Kuah | 25 | 3 | sedang
tag: berkuah, sehat
desc: Aneka sayur dalam kuah kental gurih.
bahan:
- broccoli* | 1/2 bonggol
- carrot* | 1 batang
- cabbage* | 3 lembar
- mustard_greens? | 1 ikat
- mushroom? | 100 g
- shrimp? | 100 g
- meatball? | 6 butir
- egg? | 1 butir
- garlic | 3 siung
- oyster_sauce? | 1 sdm
- flour? | 1 sdt maizena/tepung untuk mengentalkan
- water | 400 ml
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Tumis bawang putih, masukkan udang dan bakso sampai berubah warna.
2. Tambahkan air, wortel, dan brokoli; masak sampai hampir empuk.
3. Masukkan kol, sawi, dan jamur; bumbui saus tiram dan garam.
4. Kentalkan dengan larutan tepung, lalu masukkan kocokan telur sambil diaduk.
alat: wajan, spatula, pisau, talenan
ganti: shrimp = ayam iris; meatball = sosis

## tumis-kangkung | Tumis Kangkung Bawang | 10 | 2 | mudah
tag: hemat, vegetarian
desc: Kangkung cepat matang dengan bumbu bawang sederhana.
bahan:
- water_spinach* | 1 ikat
- garlic | 3 siung
- shallot | 3 siung
- chili? | 3 buah
- oyster_sauce? | 1 sdm
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Petik kangkung, cuci bersih, tiriskan.
2. Tumis bawang merah, bawang putih, dan cabai sampai harum.
3. Masukkan kangkung dengan api besar, aduk cepat.
4. Bumbui saus tiram dan garam, angkat begitu layu.
tip: Masak dengan api besar dan sebentar supaya kangkung tetap hijau.
alat: wajan, spatula, pisau, talenan
ganti: water_spinach = bayam atau sawi

## perkedel-kentang | Perkedel Kentang | 40 | 4 | sedang
tag: camilan, anak, hemat, vegetarian
desc: Kentang tumbuk berbumbu, digoreng dengan balutan telur.
bahan:
- potato* | 4 buah
- egg* | 1 butir
- spring_onion? | 1 batang
- celery? | 1 batang
- shallot | 4 siung, goreng
- salt | 1 sdt
- pepper | 1/2 sdt
- cooking_oil | untuk menggoreng
langkah:
1. Goreng atau kukus kentang, lalu haluskan selagi panas.
2. Campur dengan bawang goreng, daun bawang, seledri, garam, dan merica.
3. Bentuk bulat pipih.
4. Celup ke kocokan telur dan goreng sampai kecokelatan.
tip: Kentang yang digoreng dulu menghasilkan perkedel lebih padat dan tidak mudah hancur.
alat: panci, wajan, spatula, garpu, mangkuk

## kentang-balado | Kentang Balado | 35 | 3 | sedang
tag: pedas, vegetarian
desc: Kentang goreng dibalut sambal merah pedas manis.
bahan:
- potato* | 4 buah
- chili* | 8 buah cabai merah
- tomato* | 1 buah
- shallot | 5 siung
- garlic | 2 siung
- sugar | 1 sdt
- salt | 1 sdt
- cooking_oil | untuk menggoreng
langkah:
1. Potong dadu kentang, goreng sampai matang dan agak kering.
2. Haluskan cabai, tomat, bawang merah, dan bawang putih.
3. Tumis bumbu halus sampai matang dan minyaknya keluar.
4. Bumbui gula dan garam, masukkan kentang dan aduk rata.
alat: wajan, spatula, ulekan, pisau, talenan
ganti: potato = telur rebus atau tempe

## sup-krim-jamur | Sup Krim Jamur | 25 | 3 | sedang
tag: berkuah, vegetarian
desc: Sup kental lembut dengan aroma jamur dan mentega.
bahan:
- mushroom* | 200 g
- milk* | 400 ml
- butter? | 2 sdm
- onion? | 1/2 buah
- garlic | 2 siung
- flour | 2 sdm
- salt | secukupnya
- pepper | secukupnya
langkah:
1. Tumis bawang bombay dan bawang putih dengan mentega.
2. Masukkan jamur iris, masak sampai layu.
3. Taburkan tepung, aduk, lalu tuang susu sedikit demi sedikit.
4. Masak sambil diaduk sampai mengental, bumbui garam dan merica.
tip: Blender sebagian sup agar teksturnya lebih creamy.
alat: panci, sendok kayu, pisau, talenan

## jamur-crispy | Jamur Crispy | 20 | 3 | mudah
tag: camilan, vegetarian
desc: Jamur tiram goreng tepung yang renyah.
bahan:
- mushroom* | 250 g jamur tiram
- flour | 100 g
- garlic | 2 siung, haluskan
- salt | 1 sdt
- pepper | 1/2 sdt
- cooking_oil | untuk menggoreng
langkah:
1. Suwir jamur, cuci dan peras sampai agak kering.
2. Lumuri jamur dengan bawang putih, garam, dan merica.
3. Gulingkan ke tepung sambil diremas agar tepung menempel.
4. Goreng di minyak panas sampai kering dan renyah.
alat: wajan, spatula, mangkuk, saringan

## oseng-zukini-wortel | Oseng Zukini Wortel | 15 | 2 | mudah
tag: sehat, vegetarian
desc: Tumisan zukini manis gurih yang cepat matang.
bahan:
- zucchini* | 1 buah
- carrot? | 1 batang
- garlic | 2 siung
- shallot | 3 siung
- chili? | 2 buah
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Potong korek api zukini dan wortel.
2. Tumis bawang dan cabai sampai harum.
3. Masukkan wortel, lalu zukini; aduk sampai layu.
4. Bumbui garam, angkat.
alat: wajan, spatula, pisau, talenan
ganti: zucchini = labu siam

## acar-timun-wortel | Acar Timun Wortel | 15 | 4 | mudah
tag: segar, tanpa-kompor, vegetarian, hemat
desc: Acar asam manis pendamping nasi goreng atau gorengan.
bahan:
- cucumber* | 2 buah
- carrot* | 1 batang
- shallot? | 5 siung utuh
- chili? | 5 buah cabai rawit utuh
- lime | 1 buah
- sugar | 2 sdm
- salt | 1/2 sdt
- water | 100 ml
langkah:
1. Potong dadu kecil mentimun dan wortel.
2. Larutkan gula, garam, dan perasan jeruk nipis di air.
3. Masukkan sayur, bawang merah, dan cabai rawit.
4. Diamkan 10 menit agar bumbu meresap.
alat: panci kecil, toples, pisau, talenan

## sambal-tomat | Sambal Tomat | 15 | 4 | mudah
tag: pedas, vegetarian, hemat
desc: Sambal goreng tomat yang cocok untuk lauk apa saja.
bahan:
- tomato* | 2 buah
- chili* | 10 buah
- shallot | 5 siung
- garlic | 2 siung
- sugar | 1 sdt
- salt | 1 sdt
- cooking_oil | 3 sdm
langkah:
1. Goreng cabai, tomat, bawang merah, dan bawang putih sampai layu.
2. Ulek kasar dengan garam dan gula.
3. Tumis kembali sebentar dengan minyak sisa gorengan.
alat: wajan, ulekan, spatula, pisau

## sup-labu-kuning | Sup Labu Kuning | 30 | 3 | mudah
tag: berkuah, sehat, anak, vegetarian
desc: Sup oranye lembut dan manis alami.
bahan:
- pumpkin* | 400 g
- milk? | 200 ml
- onion | 1/2 buah
- garlic | 2 siung
- butter? | 1 sdm
- salt | secukupnya
- pepper | secukupnya
- water | 300 ml
langkah:
1. Tumis bawang bombay dan bawang putih dengan mentega.
2. Masukkan labu potong dan air, rebus sampai sangat empuk.
3. Blender sampai halus, kembalikan ke panci.
4. Tambahkan susu, bumbui garam dan merica, didihkan sebentar.
alat: panci, blender, pisau, talenan
ganti: milk = santan; pumpkin = wortel

## oseng-paprika-jamur | Oseng Paprika Jamur | 15 | 2 | mudah
tag: sehat, vegetarian
desc: Tumisan warna-warni dengan saus tiram.
bahan:
- bell_pepper* | 1 buah
- mushroom* | 150 g
- onion? | 1/2 buah
- garlic | 2 siung
- oyster_sauce? | 1 sdm
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Potong paprika dan jamur.
2. Tumis bawang putih dan bawang bombay.
3. Masukkan jamur, lalu paprika; aduk dengan api besar.
4. Bumbui saus tiram dan garam.
alat: wajan, spatula, pisau, talenan

## sup-lobak | Sup Lobak Bakso | 30 | 3 | mudah
tag: berkuah, hemat
desc: Sup bening segar dengan lobak manis.
bahan:
- radish* | 1 buah
- carrot? | 1 batang
- meatball? | 10 butir
- spring_onion? | 1 batang
- garlic | 3 siung
- salt | secukupnya
- pepper | secukupnya
- water | 1 liter
langkah:
1. Kupas dan potong lobak serta wortel.
2. Tumis bawang putih, tuang air, didihkan.
3. Masukkan lobak, wortel, dan bakso; masak sampai lobak bening.
4. Bumbui garam dan merica, taburi daun bawang.
alat: panci, sendok sayur, pisau, talenan
ganti: meatball = ayam suwir

## tumis-asparagus-udang | Tumis Asparagus Udang | 15 | 2 | mudah
tag: sehat
desc: Tumisan cepat dengan rasa manis udang dan renyah asparagus.
bahan:
- asparagus* | 1 ikat
- shrimp* | 150 g
- garlic | 3 siung
- oyster_sauce? | 1 sdm
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Potong asparagus 4 cm, buang pangkal yang keras.
2. Tumis bawang putih, masukkan udang sampai berubah warna.
3. Masukkan asparagus, aduk dengan api besar.
4. Bumbui saus tiram dan garam.
alat: wajan, spatula, pisau, talenan
ganti: asparagus = buncis; shrimp = jamur untuk versi vegetarian

## tumis-kol-telur | Tumis Kol Telur | 15 | 2 | mudah
tag: hemat
desc: Kol manis dengan orak-arik telur, lauk sederhana yang mengenyangkan.
bahan:
- cabbage* | 1/4 buah
- egg* | 2 butir
- garlic | 2 siung
- shallot | 3 siung
- chili? | 2 buah
- salt | secukupnya
- cooking_oil | 1 sdm
langkah:
1. Iris kol kasar.
2. Tumis bawang dan cabai, masukkan telur dan orak-arik.
3. Masukkan kol, aduk sampai layu.
4. Bumbui garam.
alat: wajan, spatula, pisau, talenan

## sayur-asem | Sayur Asem | 40 | 4 | sedang
tag: berkuah, segar, sehat, vegetarian
desc: Sayur berkuah asam segar khas rumahan.
bahan:
- squash* | 1 buah labu siam
- corn* | 1 buah
- long_bean? | 5 batang
- peanut? | 2 sdm
- tomato? | 1 buah
- chili? | 2 buah
- shallot | 4 siung
- palm_sugar | 1 sdm
- salt | 1 sdt
- water | 1,2 liter
langkah:
1. Haluskan bawang merah dan cabai, rebus bersama air.
2. Masukkan jagung dan kacang tanah, masak 10 menit.
3. Tambahkan labu siam, kacang panjang, dan tomat.
4. Bumbui gula merah dan garam; beri asam jawa bila ada.
tip: Asam jawa memberi rasa asam khas; tomat matang bisa menggantikannya.
alat: panci, sendok sayur, pisau, talenan

## sup-kundur | Sup Kundur Bening | 25 | 3 | mudah
tag: berkuah, sehat, hemat
desc: Sup ringan dan menyegarkan dengan kundur yang lembut.
bahan:
- winter_melon* | 400 g
- carrot? | 1 batang
- meatball? | 8 butir
- garlic | 3 siung
- salt | secukupnya
- pepper | secukupnya
- water | 1 liter
langkah:
1. Kupas kundur, buang bijinya, potong dadu.
2. Tumis bawang putih, tuang air dan didihkan.
3. Masukkan kundur, wortel, dan bakso; masak sampai kundur bening.
4. Bumbui garam dan merica.
alat: panci, sendok sayur, pisau, talenan
ganti: winter_melon = labu siam

## gado-gado | Gado-gado Rumahan | 40 | 3 | sedang
tag: sehat, vegetarian
desc: Sayur rebus dengan saus kacang gurih manis.
bahan:
- cabbage* | 1/4 buah
- potato* | 2 buah
- egg* | 2 butir
- peanut | 150 g kacang goreng atau 4 sdm selai kacang
- bean_sprout? | 1 genggam
- long_bean? | 5 batang
- tofu? | 2 potong
- tempeh? | 1 papan kecil
- cucumber? | 1 buah
- palm_sugar | 30 g
- chili? | 2 buah
- lime? | 1/2 buah
- garlic | 1 siung
- salt | secukupnya
langkah:
1. Rebus kentang, telur, kol, tauge, dan kacang panjang sampai matang.
2. Goreng tahu dan tempe.
3. Haluskan kacang, gula merah, cabai, bawang putih, garam, dan air hangat sampai kental; beri perasan jeruk nipis.
4. Tata sayur, kentang, telur, tahu, tempe, dan mentimun, siram saus kacang.
alat: panci, ulekan, piring, pisau, talenan

## artichoke-kukus | Artichoke Kukus Saus Mentega Lemon | 40 | 2 | sedang
tag: sehat, vegetarian
desc: Artichoke kukus dicocol mentega leleh berperasa lemon.
bahan:
- artichoke* | 2 buah
- butter* | 3 sdm
- lemon* | 1 buah
- garlic | 1 siung
- salt | sejumput
langkah:
1. Potong ujung artichoke dan gosok bekas potongan dengan lemon.
2. Kukus 30-40 menit sampai daun mudah dicabut.
3. Lelehkan mentega dengan bawang putih cincang, perasan lemon, dan garam.
4. Cabut daun satu per satu, cocol ke saus, gigit bagian pangkalnya.
alat: kukusan, pisau, talenan, mangkuk

## salad-sayur-segar | Salad Sayur Segar | 10 | 2 | mudah
tag: segar, sehat, tanpa-kompor, vegetarian
desc: Salad renyah dengan saus jeruk madu.
bahan:
- cucumber* | 1 buah
- tomato* | 2 buah
- lettuce? | 4 lembar
- carrot? | 1 batang, serut
- cheese? | 2 sdm, parut
- lemon? | 1/2 buah
- honey? | 1 sdt
- salt | sejumput
- pepper | sejumput
langkah:
1. Potong mentimun dan tomat, sobek selada.
2. Campur perasan lemon, madu, garam, dan merica untuk saus.
3. Aduk sayur dengan saus tepat sebelum disajikan, taburi keju.
alat: pisau, talenan, mangkuk
ganti: lemon = jeruk nipis

## pasta-aglio-olio | Pasta Aglio Olio | 20 | 2 | mudah
tag: pedas
desc: Pasta minyak bawang putih yang sederhana tapi harum.
bahan:
- pasta* | 200 g spaghetti
- garlic* | 6 siung
- chili? | 3 buah atau cabai kering
- shrimp? | 100 g
- cheese? | 2 sdm parut
- cooking_oil | 4 sdm (lebih baik minyak zaitun)
- salt | secukupnya
langkah:
1. Rebus pasta dalam air bergaram sampai al dente, simpan sedikit air rebusannya.
2. Panaskan minyak dengan api kecil, tumis irisan bawang putih dan cabai sampai keemasan.
3. Masukkan udang bila ada, masak sampai matang.
4. Masukkan pasta dan sedikit air rebusan, aduk cepat; taburi keju.
tip: Api kecil penting agar bawang putih tidak pahit.
alat: panci, wajan, spatula, talenan, pisau

## pasta-saus-tomat | Pasta Saus Tomat Segar | 25 | 2 | mudah
tag: anak, vegetarian
desc: Pasta dengan saus dari tomat segar, tanpa saus botolan.
bahan:
- pasta* | 200 g
- tomato* | 5 buah
- onion | 1/2 buah
- garlic | 3 siung
- mushroom? | 100 g
- cheese? | 3 sdm parut
- sugar | 1 sdt
- salt | secukupnya
- cooking_oil | 2 sdm
langkah:
1. Rebus pasta sampai al dente.
2. Tumis bawang bombay dan bawang putih, masukkan jamur.
3. Masukkan tomat cincang, gula, dan garam; masak sampai menjadi saus kental.
4. Aduk pasta dengan saus, taburi keju.
alat: panci, wajan, spatula, talenan, pisau

## makaroni-keju | Makaroni Keju Teflon | 20 | 2 | mudah
tag: anak, vegetarian
desc: Makaroni creamy dengan saus keju susu.
bahan:
- pasta* | 150 g makaroni
- cheese* | 100 g parut
- milk* | 250 ml
- butter? | 1 sdm
- flour | 1 sdm
- salt | secukupnya
- pepper | sejumput
langkah:
1. Rebus makaroni sampai matang, tiriskan.
2. Lelehkan mentega, masukkan tepung dan aduk sebentar.
3. Tuang susu sedikit demi sedikit sampai mengental, masukkan keju.
4. Campur makaroni dengan saus, bumbui garam dan merica.
alat: panci, sendok kayu, parutan

## nasi-goreng-telur | Nasi Goreng Telur | 15 | 2 | mudah
tag: sarapan, hemat
desc: Nasi goreng kecap rumahan dengan telur orak-arik.
bahan:
- rice* | 2 piring nasi dingin
- egg* | 2 butir
- shallot | 4 siung
- garlic | 2 siung
- sweet_soy_sauce? | 2 sdm
- chili? | 2 buah
- spring_onion? | 1 batang
- salt | secukupnya
- cooking_oil | 2 sdm
langkah:
1. Haluskan atau iris bawang merah, bawang putih, dan cabai.
2. Tumis bumbu, sisihkan ke pinggir, orak-arik telur.
3. Masukkan nasi, aduk rata dengan api besar.
4. Tambahkan kecap dan garam, taburi daun bawang.
tip: Nasi sisa semalam membuat nasi goreng tidak lembek.
alat: wajan, spatula, mangkuk, pisau
ganti: egg = sosis atau bakso

## mie-goreng-telur-sayur | Mie Goreng Telur Sayur | 15 | 2 | mudah
tag: hemat
desc: Mie goreng sederhana dengan sayur dan telur.
bahan:
- noodle* | 2 bungkus/keping
- egg* | 2 butir
- cabbage? | 2 lembar
- carrot? | 1/2 batang
- mustard_greens? | 1 ikat kecil
- garlic | 2 siung
- shallot | 3 siung
- sweet_soy_sauce? | 2 sdm
- salt | secukupnya
- cooking_oil | 2 sdm
langkah:
1. Rebus mie setengah matang, tiriskan.
2. Tumis bawang, masukkan telur dan orak-arik.
3. Masukkan sayuran, aduk sampai layu.
4. Masukkan mie dan kecap, aduk rata.
alat: panci, wajan, spatula, pisau, talenan

## mie-kuah-telur | Mie Kuah Telur Sawi | 10 | 1 | mudah
tag: berkuah, hemat
desc: Semangkuk mie hangat, cepat untuk malam hari.
bahan:
- noodle* | 1 bungkus/keping
- egg* | 1 butir
- mustard_greens? | 2 batang
- tomato? | 1/2 buah
- spring_onion? | 1 batang
- garlic | 1 siung
- water | 400 ml
langkah:
1. Didihkan air dengan bawang putih geprek.
2. Masukkan mie dan sawi.
3. Pecahkan telur ke dalam kuah, jangan diaduk sampai setengah matang.
4. Tambahkan tomat dan daun bawang, bumbui sesuai selera.
alat: panci, sendok sayur, mangkuk

## kentang-goreng | Kentang Goreng Rumahan | 30 | 2 | mudah
tag: camilan, anak, vegetarian, hemat
desc: Kentang goreng renyah buatan sendiri.
bahan:
- potato* | 3 buah
- salt | secukupnya
- cooking_oil | untuk menggoreng
langkah:
1. Potong kentang memanjang, rendam di air dingin 10 menit, keringkan.
2. Goreng di minyak sedang sampai matang tapi belum cokelat, angkat.
3. Goreng lagi di minyak panas sampai renyah keemasan.
4. Taburi garam.
tip: Penggorengan dua kali adalah kunci renyah.
alat: wajan, spatula, saringan, pisau, talenan

## udang-goreng-mentega | Udang Goreng Mentega | 20 | 2 | sedang
tag: anak
desc: Udang goreng dengan saus mentega kecap yang harum.
bahan:
- shrimp* | 250 g
- butter* | 2 sdm
- garlic | 3 siung
- onion? | 1/2 buah
- sweet_soy_sauce? | 2 sdm
- lime? | 1/2 buah
- salt | secukupnya
- cooking_oil | untuk menggoreng
langkah:
1. Lumuri udang dengan perasan jeruk nipis dan garam, goreng sebentar.
2. Lelehkan mentega, tumis bawang putih dan bawang bombay.
3. Tambahkan kecap dan sedikit air.
4. Masukkan udang, aduk sampai saus melapisi udang.
alat: wajan, spatula, mangkuk

## udang-saus-padang | Udang Saus Padang | 25 | 2 | sedang
tag: pedas
desc: Udang dalam saus merah pedas manis.
bahan:
- shrimp* | 250 g
- tomato* | 2 buah
- chili* | 5 buah
- bell_pepper? | 1/2 buah
- onion? | 1/2 buah
- garlic | 3 siung
- shallot | 4 siung
- sugar | 1 sdt
- salt | secukupnya
- cooking_oil | 2 sdm
langkah:
1. Haluskan cabai, bawang merah, bawang putih, dan satu tomat.
2. Tumis bumbu halus dan bawang bombay sampai harum.
3. Masukkan udang, paprika, dan tomat potong.
4. Bumbui gula dan garam, masak sampai udang matang dan saus mengental.
alat: wajan, spatula, blender, pisau, talenan
ganti: shrimp = ayam atau tahu

## kepiting-saus-tiram | Kepiting Saus Tiram | 30 | 2 | sulit
tag: berkuah
desc: Kepiting dimasak dalam saus tiram jahe.
bahan:
- crab* | 2 ekor
- oyster_sauce | 2 sdm
- ginger? | 1 ruas
- garlic | 4 siung
- spring_onion? | 1 batang
- sugar | 1 sdt
- water | 150 ml
- cooking_oil | 2 sdm
langkah:
1. Bersihkan kepiting, potong dua, kukus 10 menit.
2. Tumis bawang putih dan jahe sampai harum.
3. Masukkan saus tiram, gula, dan air.
4. Masukkan kepiting, aduk sampai saus meresap, taburi daun bawang.
alat: wajan, spatula, pisau, talenan

## salad-jeruk-bali-udang | Salad Jeruk Bali Udang | 20 | 2 | sedang
tag: segar, pedas
desc: Salad asam manis pedas dengan bulir jeruk bali.
bahan:
- grapefruit* | 1/2 buah
- shrimp* | 150 g, rebus
- cucumber? | 1/2 buah
- chili? | 2 buah
- lime? | 1 buah
- peanut? | 2 sdm sangrai
- sugar | 1 sdt
- salt | sejumput
langkah:
1. Kupas jeruk bali, ambil bulirnya.
2. Rebus udang 2-3 menit, tiriskan.
3. Campur perasan jeruk nipis, cabai iris, gula, dan garam untuk saus.
4. Aduk jeruk bali, udang, dan mentimun dengan saus, taburi kacang.
alat: panci, pisau, talenan, mangkuk

## tempe-orek | Tempe Orek Kecap | 20 | 3 | mudah
tag: hemat, vegetarian
desc: Tempe goreng kering berbalut kecap manis pedas.
bahan:
- tempeh* | 1 papan
- sweet_soy_sauce | 3 sdm
- chili? | 3 buah
- shallot | 4 siung
- garlic | 2 siung
- salt | secukupnya
- cooking_oil | untuk menggoreng
langkah:
1. Potong korek api tempe, goreng sampai kering.
2. Tumis bawang dan cabai iris.
3. Masukkan kecap dan sedikit garam, masukkan tempe.
4. Aduk sampai kecap mengering dan melapisi tempe.
alat: wajan, spatula, pisau, talenan

## tahu-telur | Tahu Telur | 25 | 2 | sedang
tag: vegetarian, hemat
desc: Dadar tahu telur dengan siraman kecap kacang.
bahan:
- tofu* | 2 potong
- egg* | 3 butir
- bean_sprout? | 1 genggam
- peanut? | 3 sdm
- sweet_soy_sauce? | 2 sdm
- garlic | 1 siung
- salt | secukupnya
- cooking_oil | 3 sdm
langkah:
1. Potong dadu tahu, campur dengan kocokan telur dan garam.
2. Goreng adonan dalam teflon seperti dadar tebal.
3. Haluskan kacang dan bawang putih, campur kecap dan air hangat.
4. Sajikan dadar dengan tauge rebus dan siraman saus kacang.
alat: wajan, spatula, mangkuk, pisau

## ayam-kecap | Ayam Kecap | 35 | 3 | sedang
tag: anak
desc: Ayam manis gurih dengan kuah kecap kental.
bahan:
- chicken* | 400 g
- sweet_soy_sauce | 4 sdm
- onion? | 1 buah
- tomato? | 1 buah
- garlic | 3 siung
- shallot | 4 siung
- pepper | 1/2 sdt
- salt | secukupnya
- water | 200 ml
- cooking_oil | 2 sdm
langkah:
1. Goreng ayam setengah matang.
2. Tumis bawang merah, bawang putih, dan bawang bombay.
3. Masukkan ayam, kecap, merica, garam, dan air.
4. Masak sampai kuah menyusut, tambahkan tomat di akhir.
alat: wajan, spatula, pisau, talenan

## cah-sawi-bakso | Cah Sawi Bakso | 15 | 2 | mudah
tag: hemat
desc: Sawi hijau ditumis bersama bakso.
bahan:
- mustard_greens* | 1 ikat
- meatball* | 8 butir
- garlic | 3 siung
- oyster_sauce? | 1 sdm
- salt | secukupnya
- water | 50 ml
- cooking_oil | 1 sdm
langkah:
1. Potong sawi dan belah bakso.
2. Tumis bawang putih, masukkan bakso.
3. Masukkan batang sawi dulu, lalu daunnya dan air.
4. Bumbui saus tiram dan garam.
alat: wajan, spatula, pisau, talenan

## puding-roti | Puding Roti Kukus | 40 | 4 | sedang
tag: manis, anak, vegetarian
desc: Roti sisa menjadi puding lembut beraroma susu.
bahan:
- bread* | 5 lembar
- milk* | 300 ml
- egg* | 2 butir
- sugar | 4 sdm
- butter? | 1 sdm
- banana? | 1 buah
langkah:
1. Sobek roti dan rendam dalam susu 10 menit.
2. Kocok telur dan gula, campur dengan roti.
3. Tuang ke wadah tahan panas yang dioles mentega, beri irisan pisang.
4. Kukus 30 menit sampai set.
alat: kukusan, loyang, mangkuk, garpu

## roti-buah-tin-keju | Roti Buah Tin Keju Madu | 10 | 2 | mudah
tag: camilan, manis, vegetarian
desc: Roti panggang dengan keju, irisan buah tin, dan madu.
bahan:
- bread* | 4 lembar
- fig* | 3 buah
- cheese* | 60 g
- honey? | 1 sdm
langkah:
1. Panggang roti sampai renyah.
2. Oles atau tata keju di atas roti.
3. Tambahkan irisan buah tin dan siram madu.
alat: oven, pisau, talenan, piring

## smoothie-persik-yoghurt | Smoothie Persik Yoghurt | 5 | 1 | mudah
tag: minuman, sehat, tanpa-kompor, vegetarian
desc: Smoothie lembut dengan rasa persik.
bahan:
- peach* | 2 buah
- yogurt* | 150 g
- honey? | 1 sdm
- ice? | 3 kotak
langkah:
1. Buang biji persik dan potong dagingnya.
2. Blender bersama yoghurt, madu, dan es.
3. Tuang ke gelas dan sajikan segera.
alat: blender, pisau, talenan, gelas

## melon-susu | Es Melon Susu | 5 | 2 | mudah
tag: minuman, manis, segar, tanpa-kompor, vegetarian
desc: Melon serut dingin dengan susu.
bahan:
- cantaloupe* | 1/2 buah
- milk* | 200 ml
- sugar? | 1 sdm
- ice | secukupnya
langkah:
1. Serut atau potong dadu daging melon.
2. Masukkan ke gelas dengan es batu.
3. Tuang susu yang sudah dicampur gula.
alat: pisau, talenan, mangkuk, sendok

## jus-nanas-timun | Jus Nanas Timun | 5 | 2 | mudah
tag: minuman, segar, sehat, tanpa-kompor, vegetarian
desc: Jus hijau kekuningan yang segar.
bahan:
- pineapple* | 1/4 buah
- cucumber* | 1 buah
- lime? | 1/2 buah
- honey? | 1 sdm
- water | 150 ml
langkah:
1. Potong nanas dan mentimun.
2. Blender dengan air sampai halus, saring bila suka.
3. Tambahkan perasan jeruk nipis dan madu.
alat: blender, pisau, talenan, gelas

## salad-delima-pir | Salad Pir Delima | 10 | 2 | mudah
tag: segar, sehat, tanpa-kompor, vegetarian
desc: Pir renyah dengan bulir delima dan keju.
bahan:
- pear* | 2 buah
- pomegranate* | 1/2 buah
- cheese? | 30 g
- lettuce? | 3 lembar
- honey? | 1 sdt
- lemon? | sedikit perasan
langkah:
1. Iris tipis pir, ambil bulir delima.
2. Tata selada, pir, dan delima di piring.
3. Siram campuran madu dan lemon, taburi keju.
alat: pisau, talenan, mangkuk

## anggur-beku | Anggur Beku Yoghurt | 5 | 2 | mudah
tag: camilan, manis, anak, tanpa-kompor, vegetarian
desc: Camilan dingin seperti es krim mini.
bahan:
- grape* | 2 genggam
- yogurt? | 100 g
- honey? | 1 sdm
langkah:
1. Cuci dan keringkan anggur.
2. Celupkan ke campuran yoghurt madu bila suka.
3. Bekukan minimal 2 jam di freezer.
alat: mangkuk, wadah tertutup, freezer

## kentang-telur-balado | Telur Kentang Balado | 35 | 3 | sedang
tag: pedas
desc: Telur rebus dan kentang goreng dalam sambal balado.
bahan:
- egg* | 4 butir
- potato* | 2 buah
- chili* | 8 buah
- tomato? | 1 buah
- shallot | 5 siung
- garlic | 2 siung
- sugar | 1 sdt
- salt | 1 sdt
- cooking_oil | untuk menggoreng
langkah:
1. Rebus telur, kupas, lalu goreng sebentar sampai kulitnya berkerut.
2. Goreng kentang dadu sampai matang.
3. Haluskan cabai, tomat, dan bawang; tumis sampai matang.
4. Bumbui gula dan garam, masukkan telur dan kentang.
alat: panci, wajan, spatula, ulekan, pisau

## nasi-uduk-sederhana | Nasi Uduk Sederhana | 40 | 4 | sedang
tag: sarapan, hemat
desc: Nasi gurih santan beraroma serai dan daun salam yang cocok untuk sarapan.
bahan:
- rice* | 3 gelas beras
- coconut_milk | 400 ml
- bay_leaf | 2 lembar
- lemongrass | 1 batang digeprek
- shallot? | 3 siung
- salt | 1 sdt
langkah:
1. Cuci beras sampai air cucian jernih, tiriskan.
2. Campur beras, santan, air secukupnya, garam, serai, dan daun salam dalam panci.
3. Masak sambil diaduk sesekali sampai air terserap, api dikecilkan.
4. Kukus atau tutup rapat 15 menit sampai nasi pulen.
5. Gembur-gemburkan nasi dengan garpu sebelum disajikan.
tip: Aduk santan terus saat mendidih agar tidak pecah.
alat: panci, sendok kayu, garpu, talenan, pisau
ganti: coconut_milk = susu cair ditambah sedikit minyak; bay_leaf = daun jeruk

## nasi-goreng-kampung | Nasi Goreng Kampung | 20 | 2 | mudah
tag: sarapan, pedas, hemat
desc: Nasi goreng pedas dengan cabai, bawang, dan tauge yang sederhana.
bahan:
- rice* | 3 piring nasi dingin
- chili* | 5 buah
- bean_sprout? | 1 genggam
- egg? | 1 butir
- shallot | 4 siung
- garlic | 2 siung
- sweet_soy_sauce | 2 sdm
- salt | 1/2 sdt
- cooking_oil | 3 sdm
langkah:
1. Haluskan cabai, bawang merah, dan bawang putih.
2. Tumis bumbu halus dengan minyak sampai harum.
3. Masukkan telur, orak-arik sampai setengah matang.
4. Tambahkan nasi, kecap, dan garam, aduk rata dengan api besar.
5. Masukkan tauge, aduk sebentar lalu angkat.
tip: Nasi dingin semalam membuat nasi goreng tidak lembek.
alat: wajan, spatula, ulekan, pisau, talenan

## nasi-goreng-sosis | Nasi Goreng Sosis | 15 | 2 | mudah
tag: sarapan, anak
desc: Nasi goreng manis gurih dengan irisan sosis kesukaan anak.
bahan:
- rice* | 3 piring nasi dingin
- sausage* | 3 buah
- egg | 1 butir
- garlic | 2 siung
- spring_onion? | 1 batang
- sweet_soy_sauce | 1 sdm
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Iris sosis tipis, cincang bawang putih.
2. Tumis bawang putih dan sosis sampai sosis agak kecokelatan.
3. Geser ke tepi, orak-arik telur di sisi lain wajan.
4. Masukkan nasi, kecap, dan garam, aduk rata.
5. Taburi irisan daun bawang lalu sajikan.
alat: wajan, spatula, pisau, talenan

## nasi-tim-ayam | Nasi Tim Ayam | 45 | 2 | sedang
tag: sehat, anak, berkuah
desc: Nasi lembut dengan ayam dan jamur yang dikukus, ramah untuk perut.
bahan:
- rice* | 1 gelas beras
- chicken* | 150 g
- mushroom | 3 buah
- ginger | 1 ruas
- spring_onion? | 1 batang
- carrot? | 1/2 buah
- salt | 1/2 sdt
- water | 400 ml
langkah:
1. Potong dadu kecil ayam, jamur, dan wortel.
2. Rebus beras dengan air sampai setengah matang menjadi bubur kental.
3. Campur ayam, jamur, wortel, jahe geprek, dan garam ke dalam mangkuk tahan panas.
4. Tuang bubur setengah matang, kukus 25 menit.
5. Taburi irisan daun bawang.
tip: Potong ayam sangat kecil agar cepat matang dan mudah dikunyah.
alat: panci, kukusan, mangkuk, pisau, talenan

## bubur-ayam | Bubur Ayam | 50 | 4 | sedang
tag: sarapan, berkuah
desc: Bubur nasi gurih dengan suwiran ayam dan taburan daun bawang.
bahan:
- rice* | 1 gelas beras
- chicken* | 250 g
- spring_onion | 2 batang
- celery? | 1 batang
- ginger | 1 ruas
- sweet_soy_sauce? | 1 sdm
- salt | 1 sdt
- water | 1,5 liter
langkah:
1. Rebus ayam dengan jahe dan sedikit garam sampai empuk, angkat dan suwir.
2. Masukkan beras ke kaldu, masak dengan api kecil sambil sering diaduk.
3. Terus masak 30 menit sampai butiran nasi pecah dan bubur kental.
4. Koreksi garam lalu sajikan dengan suwiran ayam.
5. Taburi daun bawang, seledri, dan kecap.
tip: Aduk dari dasar panci agar bubur tidak gosong.
alat: panci, sendok kayu, pisau, talenan, mangkuk

## nasi-kuning-sederhana | Nasi Kuning Sederhana | 40 | 4 | sedang
tag: hemat
desc: Nasi wangi berwarna kuning dari kunyit dan santan.
bahan:
- rice* | 3 gelas beras
- turmeric | 1 ruas, dihaluskan
- coconut_milk | 400 ml
- lemongrass | 1 batang digeprek
- bay_leaf | 2 lembar
- salt | 1 sdt
langkah:
1. Cuci beras lalu tiriskan.
2. Rebus santan bersama kunyit halus, serai, daun salam, dan garam sampai mendidih.
3. Masukkan beras, aduk sampai cairan terserap.
4. Kukus 20 menit sampai pulen.
5. Aduk perlahan dan sajikan hangat.
tip: Saring air kunyit agar warna nasi rata dan tidak berbutir.
alat: panci, kukusan, sendok kayu, saringan
ganti: turmeric = kunyit bubuk 1 sdt

## nasi-gila | Nasi Gila | 25 | 2 | sedang
tag: pedas
desc: Nasi goreng pedas berisi sosis, bakso, dan telur.
bahan:
- rice* | 3 piring nasi dingin
- sausage* | 2 buah
- meatball* | 4 butir
- egg | 2 butir
- chili | 5 buah
- garlic | 3 siung
- shallot | 3 siung
- sweet_soy_sauce | 2 sdm
- cooking_oil | 3 sdm
langkah:
1. Haluskan cabai, bawang putih, dan bawang merah.
2. Tumis bumbu sampai harum, masukkan sosis dan bakso yang diiris.
3. Masukkan telur, orak-arik, lalu tambahkan nasi.
4. Bumbui kecap, aduk rata dengan api besar sampai wangi.
tip: Tambah cabai sesuai selera pedas.
alat: wajan, spatula, ulekan, pisau, talenan

## mie-goreng-jawa | Mie Goreng Jawa | 25 | 2 | sedang
tag: pedas
desc: Mie goreng berbumbu kecap manis dengan sawi dan telur.
bahan:
- noodle* | 2 bungkus
- mustard_greens* | 3 batang
- egg | 1 butir
- shallot | 3 siung
- garlic | 2 siung
- sweet_soy_sauce | 2 sdm
- chili? | 2 buah
- cooking_oil | 3 sdm
langkah:
1. Rebus mie sebentar sampai lunak, tiriskan.
2. Tumis bawang merah, bawang putih, dan cabai iris sampai harum.
3. Masukkan telur, orak-arik, lalu sawi iris.
4. Masukkan mie dan kecap, aduk cepat dengan api besar.
5. Angkat saat sawi masih sedikit renyah.
alat: panci, wajan, spatula, saringan, pisau, talenan

## mie-rebus-telur | Mie Rebus Telur | 15 | 1 | mudah
tag: berkuah, hemat
desc: Mie berkuah hangat dengan telur dan sawi untuk malam hari.
bahan:
- noodle* | 1 bungkus
- egg* | 1 butir
- mustard_greens | 2 batang
- garlic | 1 siung
- spring_onion? | 1 batang
- salt | 1/2 sdt
- water | 400 ml
langkah:
1. Didihkan air bersama bawang putih geprek dan garam.
2. Masukkan mie, masak 2 menit.
3. Pecahkan telur ke dalam kuah, tambahkan sawi.
4. Masak 1 menit lagi sampai telur setengah matang, taburi daun bawang.
alat: panci, sendok sayur, mangkuk

## telur-balado | Telur Balado | 25 | 3 | mudah
tag: pedas, hemat
desc: Telur rebus goreng dalam sambal cabai merah yang pedas manis.
bahan:
- egg* | 4 butir
- chili* | 8 buah
- tomato | 1 buah
- shallot | 4 siung
- garlic | 2 siung
- sugar | 1 sdt
- salt | 1/2 sdt
- cooking_oil | 4 sdm
langkah:
1. Rebus telur 10 menit, kupas.
2. Goreng telur sebentar sampai permukaannya berkerut.
3. Haluskan cabai, tomat, bawang merah, dan bawang putih.
4. Tumis sambal sampai matang dan minyak keluar, bumbui gula dan garam.
5. Masukkan telur, aduk sampai terbalut sambal.
alat: panci, wajan, spatula, ulekan, pisau

## telur-dadar-padang | Telur Dadar Padang | 20 | 2 | sedang
tag: sarapan
desc: Dadar tebal dengan cincangan bawang dan cabai, renyah di pinggir.
bahan:
- egg* | 3 butir
- shallot | 3 siung
- spring_onion | 1 batang
- chili? | 2 buah
- flour | 1 sdm
- salt | 1/2 sdt
- cooking_oil | 4 sdm
langkah:
1. Kocok telur dengan tepung, garam, bawang merah iris, daun bawang, dan cabai.
2. Panaskan minyak lebih banyak dari biasa di wajan kecil.
3. Tuang adonan, masak dengan api sedang sampai bawahnya kecokelatan.
4. Balik hati-hati, masak sisi lain sampai matang.
5. Angkat, tiriskan, lalu potong-potong.
tip: Wajan kecil membuat dadar tebal dan tidak mudah patah.
alat: wajan, spatula, mangkuk, garpu, pisau, talenan

## telur-gulung-sosis | Telur Gulung Sosis | 15 | 2 | mudah
tag: sarapan, anak, camilan
desc: Dadar tipis yang digulung dengan sosis di dalamnya.
bahan:
- egg* | 3 butir
- sausage* | 3 buah
- milk? | 2 sdm
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Kocok telur dengan susu dan garam.
2. Panaskan teflon dengan sedikit minyak, tuang sedikit telur tipis.
3. Letakkan sosis di tepi, gulung sebelum telur benar-benar kering.
4. Tuang lagi adonan, gulung ulang sampai habis.
5. Potong-potong setelah agak dingin.
alat: teflon, spatula, mangkuk, garpu, pisau, talenan

## sup-telur-tomat | Sup Telur Tomat | 15 | 2 | mudah
tag: berkuah, sehat, hemat
desc: Sup bening asam segar dengan pita telur lembut.
bahan:
- egg* | 2 butir
- tomato* | 2 buah
- spring_onion | 1 batang
- garlic | 1 siung
- salt | 1/2 sdt
- pepper | 1/4 sdt
- water | 500 ml
langkah:
1. Tumis bawang putih cincang sebentar, masukkan tomat potong.
2. Tuang air, didihkan sampai tomat lunak.
3. Bumbui garam dan merica.
4. Tuang telur kocok perlahan sambil diaduk membentuk pita.
5. Taburi daun bawang, matikan api.
alat: panci, sendok sayur, mangkuk, garpu, pisau, talenan

## tahu-crispy | Tahu Crispy | 20 | 3 | mudah
tag: camilan, hemat, vegetarian
desc: Tahu goreng berbalut tepung renyah, enak dengan sambal.
bahan:
- tofu* | 6 potong
- flour | 5 sdm
- garlic | 2 siung
- salt | 1/2 sdt
- pepper | 1/4 sdt
- water | 5 sdm
- cooking_oil | secukupnya
langkah:
1. Potong tahu, lumuri bawang putih halus, garam, dan merica.
2. Campur tepung dengan air dan sedikit garam jadi adonan kental.
3. Panaskan minyak banyak di wajan.
4. Celup tahu ke adonan lalu goreng sampai keemasan dan renyah.
5. Tiriskan di kertas dapur.
tip: Minyak harus benar-benar panas agar tepung tidak menyerap minyak.
alat: wajan, spatula, mangkuk, pisau, talenan, saringan

## tahu-bacem | Tahu Bacem | 40 | 3 | sedang
tag: hemat, vegetarian
desc: Tahu dimasak lama dalam gula merah dan kecap sampai meresap.
bahan:
- tofu* | 8 potong
- palm_sugar | 3 sdm
- sweet_soy_sauce | 3 sdm
- bay_leaf | 2 lembar
- shallot | 3 siung
- garlic | 2 siung
- salt | 1/2 sdt
- water | 400 ml
langkah:
1. Haluskan bawang merah dan bawang putih.
2. Rebus air dengan bumbu halus, gula merah, kecap, daun salam, dan garam.
3. Masukkan tahu, masak dengan api kecil sampai air menyusut dan meresap.
4. Goreng atau panggang sebentar di teflon sampai tepinya cokelat.
tip: Rendam tahu dalam bumbu semalam bila ingin lebih meresap.
alat: panci, teflon, spatula, ulekan, pisau, talenan

## tempe-bacem | Tempe Bacem | 40 | 3 | sedang
tag: hemat, vegetarian
desc: Tempe manis gurih berwarna cokelat tua khas Jawa.
bahan:
- tempeh* | 1 papan
- palm_sugar | 3 sdm
- sweet_soy_sauce | 2 sdm
- bay_leaf | 2 lembar
- shallot | 3 siung
- garlic | 2 siung
- salt | 1/2 sdt
- water | 400 ml
langkah:
1. Potong tempe menjadi 8 bagian.
2. Haluskan bawang merah dan bawang putih.
3. Rebus air dengan bumbu, gula merah, kecap, daun salam, dan garam.
4. Masukkan tempe, masak dengan api kecil sampai air menyusut.
5. Goreng sebentar atau panggang di teflon sampai bagian luar agak kering.
alat: panci, teflon, spatula, ulekan, pisau, talenan

## tempe-mendoan | Tempe Mendoan | 20 | 3 | mudah
tag: camilan, hemat, vegetarian
desc: Tempe tipis berselimut tepung berbumbu, digoreng setengah matang.
bahan:
- tempeh* | 1 papan
- flour | 6 sdm
- spring_onion | 2 batang
- garlic | 2 siung
- salt | 1/2 sdt
- water | 6 sdm
- cooking_oil | secukupnya
langkah:
1. Iris tempe tipis lebar.
2. Campur tepung, air, bawang putih halus, garam, dan irisan daun bawang.
3. Celup tempe ke adonan sampai terbalut rata.
4. Goreng dengan minyak panas sebentar saja sampai tepung matang dan tempe masih lemas.
5. Angkat dan sajikan dengan cabai rawit.
tip: Jangan digoreng terlalu lama, ciri mendoan adalah teksturnya yang lemas.
alat: wajan, spatula, mangkuk, pisau, talenan

## tahu-isi-sayur | Tahu Isi Sayur | 30 | 3 | sedang
tag: camilan, vegetarian
desc: Tahu goreng kosong yang diisi tumisan wortel dan tauge.
bahan:
- tofu* | 6 potong
- carrot* | 1 buah
- bean_sprout | 1 genggam
- flour | 4 sdm
- garlic | 2 siung
- salt | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Goreng tahu sebentar, belah bagian tengah membentuk kantong.
2. Tumis bawang putih, wortel parut, dan tauge sampai layu, bumbui garam.
3. Isi tahu dengan tumisan.
4. Campur tepung dengan air jadi adonan, celup tahu isi.
5. Goreng sampai kering dan keemasan.
alat: wajan, spatula, parutan, pisau, talenan, mangkuk

## sambal-goreng-tempe-kentang | Sambal Goreng Tempe Kentang | 35 | 4 | sedang
tag: pedas, hemat
desc: Tempe dan kentang kering dalam bumbu cabai merah manis pedas.
bahan:
- tempeh* | 1 papan
- potato* | 2 buah
- chili | 8 buah
- shallot | 5 siung
- garlic | 2 siung
- palm_sugar | 1 sdm
- bay_leaf | 2 lembar
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Potong dadu kecil tempe dan kentang, goreng sampai kering lalu tiriskan.
2. Haluskan cabai, bawang merah, dan bawang putih.
3. Tumis bumbu dengan daun salam sampai harum dan berminyak.
4. Tambahkan gula merah dan garam.
5. Masukkan tempe dan kentang, aduk sampai bumbu merata.
alat: wajan, spatula, ulekan, pisau, talenan, saringan

## oseng-tempe-kacang-panjang | Oseng Tempe Kacang Panjang | 20 | 3 | mudah
tag: hemat, pedas
desc: Oseng sederhana dengan kecap dan cabai iris.
bahan:
- tempeh* | 1/2 papan
- long_bean* | 150 g
- shallot | 3 siung
- garlic | 2 siung
- chili? | 3 buah
- sweet_soy_sauce | 2 sdm
- cooking_oil | 2 sdm
langkah:
1. Potong dadu tempe dan goreng sebentar sampai agak kering.
2. Potong kacang panjang sepanjang 3 cm.
3. Tumis bawang merah, bawang putih, dan cabai sampai harum.
4. Masukkan kacang panjang, masak 3 menit, lalu tempe dan kecap.
5. Aduk sampai bumbu meresap.
alat: wajan, spatula, pisau, talenan

## sayur-lodeh | Sayur Lodeh | 40 | 4 | sedang
tag: berkuah, vegetarian
desc: Sayur berkuah santan dengan labu siam, terong, dan kacang panjang.
bahan:
- squash* | 1 buah
- coconut_milk | 400 ml
- eggplant | 1 buah
- long_bean | 100 g
- tempeh? | 1/2 papan
- shallot | 4 siung
- garlic | 2 siung
- candlenut | 3 butir
- turmeric | 1 ruas
- bay_leaf | 2 lembar
- lemongrass | 1 batang
- salt | 1 sdt
langkah:
1. Haluskan bawang merah, bawang putih, kemiri, dan kunyit.
2. Tumis bumbu dengan daun salam dan serai sampai harum.
3. Tuang air dan masukkan labu siam dan terong, masak sampai setengah empuk.
4. Masukkan kacang panjang, tempe, dan santan, aduk sesekali.
5. Masak sampai sayur empuk, koreksi garam.
tip: Jangan ditutup rapat setelah santan masuk agar tidak pecah.
alat: panci, ulekan, sendok sayur, pisau, talenan

## sayur-bening-bayam-jagung | Sayur Bening Bayam Jagung | 20 | 3 | mudah
tag: berkuah, sehat, hemat, vegetarian
desc: Sayur bening ringan dengan jagung manis yang menyegarkan.
bahan:
- spinach* | 1 ikat
- corn* | 1 buah
- shallot | 3 siung
- garlic | 2 siung
- salt | 1 sdt
- sugar | 1/2 sdt
- water | 800 ml
langkah:
1. Pipil jagung atau potong-potong bersama bonggolnya.
2. Didihkan air bersama bawang merah dan bawang putih iris.
3. Masukkan jagung, masak 10 menit sampai empuk.
4. Bumbui garam dan gula.
5. Masukkan bayam, masak 1 menit saja lalu angkat.
tip: Bayam masuk terakhir agar warnanya tetap hijau.
alat: panci, sendok sayur, pisau, talenan

## tumis-buncis-wortel | Tumis Buncis Wortel | 15 | 2 | mudah
tag: sehat, hemat, vegetarian
desc: Tumisan sayur renyah dengan bumbu bawang sederhana.
bahan:
- green_bean* | 150 g
- carrot* | 1 buah
- garlic | 2 siung
- shallot | 2 siung
- oyster_sauce? | 1 sdm
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Potong buncis dan iris wortel korek api.
2. Tumis bawang merah dan bawang putih sampai harum.
3. Masukkan wortel, masak 2 menit, lalu buncis.
4. Bumbui garam, saus tiram, dan sedikit air.
5. Masak sebentar sampai sayur matang tapi tetap renyah.
alat: wajan, spatula, pisau, talenan

## cah-sawi-bawang-putih | Cah Sawi Bawang Putih | 10 | 2 | mudah
tag: sehat, hemat, vegetarian
desc: Sawi hijau tumis cepat dengan bawang putih yang harum.
bahan:
- mustard_greens* | 1 ikat
- garlic* | 4 siung
- oyster_sauce? | 1 sdm
- salt | 1/4 sdt
- pepper | sedikit
- cooking_oil | 1 sdm
langkah:
1. Potong sawi sepanjang 5 cm, cincang bawang putih.
2. Tumis bawang putih dengan minyak sampai harum.
3. Masukkan batang sawi, masak 1 menit, lalu daun.
4. Bumbui saus tiram, garam, dan merica.
5. Angkat segera agar sawi tetap renyah.
alat: wajan, spatula, pisau, talenan

## terong-balado | Terong Balado | 25 | 3 | mudah
tag: pedas, hemat, vegetarian
desc: Terong goreng dengan sambal merah yang pedas manis.
bahan:
- eggplant* | 2 buah
- chili* | 8 buah
- tomato | 1 buah
- shallot | 4 siung
- garlic | 2 siung
- sugar | 1 sdt
- salt | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Potong terong, goreng sampai kecokelatan dan lunak.
2. Haluskan cabai, tomat, bawang merah, dan bawang putih.
3. Tumis sambal sampai matang dan harum.
4. Bumbui gula dan garam.
5. Masukkan terong, aduk perlahan sampai terbalut.
alat: wajan, spatula, ulekan, pisau, talenan

## urap-sayur | Urap Sayur | 30 | 3 | sedang
tag: sehat, vegetarian
desc: Sayuran rebus dengan kelapa parut berbumbu.
bahan:
- coconut* | 1/2 butir parut
- spinach* | 1 ikat
- bean_sprout | 1 genggam
- long_bean | 100 g
- chili | 3 buah
- garlic | 2 siung
- palm_sugar | 1 sdt
- salt | 1 sdt
- bay_leaf | 1 lembar
langkah:
1. Rebus bayam, tauge, dan kacang panjang sebentar, tiriskan.
2. Haluskan cabai, bawang putih, gula merah, dan garam.
3. Campur bumbu dengan kelapa parut dan daun salam.
4. Kukus kelapa berbumbu 10 menit.
5. Aduk sayur dengan kelapa kukus sebelum disajikan.
alat: panci, kukusan, ulekan, saringan, mangkuk

## pecel-sayur | Pecel Sayur | 30 | 3 | sedang
tag: sehat, vegetarian, pedas
desc: Sayur rebus disiram saus kacang pedas manis.
bahan:
- peanut | 100 g
- spinach* | 1 ikat
- bean_sprout | 1 genggam
- long_bean | 100 g
- chili | 4 buah
- garlic | 2 siung
- palm_sugar | 1 sdm
- lime | 1/2 buah
- salt | 1/2 sdt
langkah:
1. Sangrai kacang tanah sampai harum.
2. Haluskan kacang bersama cabai, bawang putih, gula merah, dan garam.
3. Encerkan dengan air hangat dan peras jeruk nipis.
4. Rebus bayam, tauge, dan kacang panjang sebentar.
5. Tata sayur dan siram dengan sambal kacang.
alat: panci, wajan, ulekan, saringan, piring

## karedok | Karedok | 20 | 2 | mudah
tag: segar, sehat, vegetarian, tanpa-kompor
desc: Sayur mentah dengan sambal kacang kencur ala Sunda yang disederhanakan.
bahan:
- cucumber* | 1 buah
- peanut | 3 sdm kacang sangrai
- cabbage | 100 g
- long_bean | 50 g
- bean_sprout? | 1 genggam
- chili | 3 buah
- garlic | 1 siung
- palm_sugar | 1 sdm
- lime | 1/2 buah
- salt | 1/2 sdt
langkah:
1. Iris mentimun, kol, dan kacang panjang halus.
2. Ulek kacang, cabai, bawang putih, gula merah, dan garam.
3. Tambahkan air dan perasan jeruk nipis sampai saus kental.
4. Campur sayur dengan saus sebelum dimakan.
tip: Campur saus saat akan makan agar sayur tetap renyah.
alat: ulekan, pisau, talenan, mangkuk

## sup-jagung-telur | Sup Jagung Telur | 20 | 3 | mudah
tag: berkuah, anak, hemat, sarapan
desc: Sup kental manis dari jagung manis dengan pita telur.
bahan:
- corn* | 2 buah
- egg* | 2 butir
- spring_onion | 1 batang
- garlic | 2 siung
- flour | 1 sdm
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 600 ml
langkah:
1. Serut jagung dari bonggolnya.
2. Tumis bawang putih sampai harum, masukkan jagung dan air.
3. Didihkan 10 menit, kentalkan dengan tepung yang dilarutkan air.
4. Bumbui garam dan merica.
5. Tuang telur kocok sambil diaduk, taburi daun bawang.
alat: panci, sendok kayu, mangkuk, pisau, talenan

## tumis-jamur-tiram | Tumis Jamur Tiram | 15 | 2 | mudah
tag: sehat, hemat, vegetarian
desc: Jamur tiram sobek tumis bawang dan kecap, gurih dan lembut.
bahan:
- mushroom* | 250 g
- garlic | 3 siung
- shallot | 2 siung
- chili? | 2 buah
- sweet_soy_sauce | 1 sdm
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Sobek jamur mengikuti seratnya, peras ringan agar air keluar.
2. Tumis bawang merah, bawang putih, dan cabai sampai harum.
3. Masukkan jamur, masak dengan api besar 3 menit.
4. Bumbui kecap dan garam, aduk sampai bumbu meresap.
alat: wajan, spatula, pisau, talenan

## capcay-goreng | Capcay Goreng | 20 | 3 | mudah
tag: sehat, vegetarian
desc: Aneka sayur yang ditumis kering dengan saus tiram.
bahan:
- cabbage* | 150 g
- carrot* | 1 buah
- mustard_greens | 3 batang
- mushroom? | 100 g
- garlic | 3 siung
- oyster_sauce | 2 sdm
- salt | 1/2 sdt
- pepper | 1/4 sdt
- cooking_oil | 2 sdm
langkah:
1. Potong semua sayur dengan ukuran sebanding.
2. Tumis bawang putih sampai harum.
3. Masukkan wortel dan jamur lebih dulu, masak 2 menit.
4. Masukkan kol dan sawi, bumbui saus tiram, garam, dan merica.
5. Masak dengan api besar singkat sampai layu tapi renyah.
alat: wajan, spatula, pisau, talenan

## sup-sayur-bakso | Sup Sayur Bakso | 25 | 4 | mudah
tag: berkuah, anak
desc: Kuah bening hangat dengan bakso, wortel, dan kentang.
bahan:
- meatball* | 8 butir
- carrot* | 1 buah
- potato | 1 buah
- cabbage? | 100 g
- celery | 1 batang
- garlic | 2 siung
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 1 liter
langkah:
1. Potong wortel dan kentang dadu, belah bakso.
2. Tumis bawang putih cincang di panci sampai harum.
3. Tuang air, masukkan wortel dan kentang, didihkan 10 menit.
4. Masukkan bakso dan kol, masak 5 menit.
5. Bumbui garam dan merica, taburi seledri.
alat: panci, sendok sayur, pisau, talenan

## ayam-goreng-bawang-putih | Ayam Goreng Bawang Putih | 40 | 3 | sedang
tag: hemat
desc: Ayam goreng berbumbu bawang putih yang gurih dan wangi.
bahan:
- chicken* | 500 g
- garlic* | 6 siung
- salt | 1 sdt
- pepper | 1/2 sdt
- sugar | 1/2 sdt
- water | 300 ml
- cooking_oil | untuk menggoreng
langkah:
1. Haluskan bawang putih bersama garam, merica, dan gula.
2. Lumuri ayam dengan bumbu, diamkan 15 menit.
3. Rebus ayam bersama bumbu dan air sampai air menyusut.
4. Goreng dalam minyak panas sampai kulit kecokelatan.
5. Tiriskan dan sajikan hangat.
tip: Direbus dulu agar bumbu meresap dan ayam matang sampai ke tulang.
alat: panci, wajan, spatula, ulekan, saringan

## ayam-bakar-kecap-teflon | Ayam Bakar Kecap Teflon | 40 | 3 | sedang
tag: hemat
desc: Ayam bakar manis gurih yang dimasak di teflon tanpa arang.
bahan:
- chicken* | 500 g
- sweet_soy_sauce | 4 sdm
- garlic | 4 siung
- shallot | 3 siung
- lime | 1/2 buah
- salt | 1 sdt
- cooking_oil | 1 sdm
langkah:
1. Haluskan bawang putih dan bawang merah, campur dengan kecap, garam, dan air jeruk nipis.
2. Lumuri ayam, diamkan 30 menit.
3. Panaskan teflon dengan sedikit minyak.
4. Panggang ayam dengan api kecil dan ditutup, balik setiap 5 menit sambil olesi sisa bumbu.
5. Angkat saat matang dan bagian luar mengilap.
tip: Api kecil mencegah kecap gosong sebelum ayam matang.
alat: teflon, penutup, kuas, ulekan, mangkuk, pisau

## ayam-rica-rica | Ayam Rica-Rica | 40 | 4 | sedang
tag: pedas
desc: Ayam tumis pedas dengan cabai, jahe, dan daun jeruk ala Manado.
bahan:
- chicken* | 500 g
- chili* | 15 buah
- shallot | 6 siung
- garlic | 3 siung
- ginger | 2 ruas
- lemongrass | 1 batang
- tomato | 1 buah
- lime | 1/2 buah
- salt | 1 sdt
- cooking_oil | 3 sdm
langkah:
1. Potong ayam, lumuri air jeruk nipis dan garam.
2. Haluskan cabai, bawang merah, bawang putih, dan jahe.
3. Tumis bumbu halus bersama serai geprek sampai harum.
4. Masukkan ayam, aduk sampai berubah warna, tambahkan tomat dan sedikit air.
5. Masak tertutup sampai ayam empuk dan air menyusut.
alat: wajan, spatula, ulekan, pisau, talenan

## sop-ayam-bening | Sop Ayam Bening | 40 | 4 | mudah
tag: berkuah, sehat
desc: Sup ayam bening dengan sayuran yang ringan dan menghangatkan.
bahan:
- chicken* | 300 g
- carrot* | 2 buah
- potato | 1 buah
- celery | 2 batang
- spring_onion | 1 batang
- garlic | 3 siung
- ginger | 1 ruas
- salt | 1 sdt
- pepper | 1/2 sdt
- water | 1,5 liter
langkah:
1. Rebus ayam dengan jahe dan sedikit garam sampai kaldu keluar.
2. Tumis bawang putih sebentar lalu masukkan ke kaldu.
3. Masukkan wortel dan kentang, masak sampai empuk.
4. Bumbui garam dan merica.
5. Taburi seledri dan daun bawang sebelum disajikan.
tip: Buang busa di permukaan agar kuah tetap bening.
alat: panci, sendok sayur, pisau, talenan

## opor-ayam | Opor Ayam | 50 | 4 | sedang
tag: berkuah
desc: Ayam masak santan putih dengan rempah halus, hidangan hari raya.
bahan:
- chicken* | 600 g
- coconut_milk | 500 ml
- shallot | 6 siung
- garlic | 4 siung
- candlenut | 4 butir
- ginger | 2 ruas
- lemongrass | 1 batang
- bay_leaf | 3 lembar
- salt | 1 sdt
- cooking_oil | 2 sdm
langkah:
1. Haluskan bawang merah, bawang putih, kemiri, dan jahe.
2. Tumis bumbu dengan serai dan daun salam sampai harum.
3. Masukkan ayam, aduk sampai berubah warna.
4. Tuang santan dan sedikit air, masak dengan api kecil sambil sesekali diaduk.
5. Masak sampai ayam empuk dan kuah mengental, bumbui garam.
tip: Aduk pelan agar santan tidak pecah.
alat: panci, wajan, ulekan, sendok kayu, pisau, talenan

## semur-daging-kentang | Semur Daging Kentang | 90 | 5 | sedang
tag: berkuah
desc: Daging dan kentang empuk dalam kuah kecap manis hangat.
bahan:
- beef* | 500 g
- potato* | 3 buah
- sweet_soy_sauce | 5 sdm
- shallot | 5 siung
- garlic | 3 siung
- cinnamon | 1 batang
- bay_leaf | 2 lembar
- pepper | 1/2 sdt
- salt | 1 sdt
- water | 800 ml
langkah:
1. Rebus daging dengan air sampai setengah empuk.
2. Tumis bawang merah dan bawang putih iris bersama kayu manis dan daun salam.
3. Masukkan ke panci daging beserta kecap, merica, dan garam.
4. Masak dengan api kecil sampai daging hampir empuk.
5. Masukkan kentang belah, masak sampai empuk dan kuah menyusut.
alat: panci, wajan, sendok kayu, pisau, talenan

## rendang-daging | Rendang Daging | 150 | 6 | sulit
tag: pedas
desc: Daging dimasak lama dengan santan dan rempah sampai kering dan hitam.
bahan:
- beef* | 700 g
- coconut_milk | 800 ml
- chili | 12 buah
- shallot | 8 siung
- garlic | 5 siung
- ginger | 2 ruas
- turmeric | 1 ruas
- candlenut | 4 butir
- lemongrass | 2 batang
- bay_leaf | 3 lembar
- salt | 1,5 sdt
langkah:
1. Haluskan cabai, bawang merah, bawang putih, jahe, kunyit, dan kemiri.
2. Campur bumbu halus, serai geprek, daun salam, daging potong, dan santan dalam wajan besar.
3. Masak dengan api sedang sambil sering diaduk sampai mendidih.
4. Kecilkan api, masak terus sekitar 2 jam sampai santan menyusut dan berminyak.
5. Aduk terus di akhir sampai bumbu kering dan warna kecokelatan gelap.
tip: Sabar mengaduk di akhir supaya tidak gosong.
alat: wajan, spatula, ulekan, pisau, talenan

## bakso-kuah-sawi | Bakso Kuah Sawi | 20 | 2 | mudah
tag: berkuah, anak
desc: Kuah bening gurih dengan bakso dan sawi hijau.
bahan:
- meatball* | 10 butir
- mustard_greens* | 3 batang
- garlic | 2 siung
- celery? | 1 batang
- spring_onion? | 1 batang
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 700 ml
langkah:
1. Tumis bawang putih cincang di panci sampai harum.
2. Tuang air, didihkan, masukkan bakso.
3. Bumbui garam dan merica.
4. Masukkan sawi, masak 1 menit.
5. Taburi seledri dan daun bawang.
alat: panci, sendok sayur, pisau, talenan

## ikan-goreng-jeruk-nipis | Ikan Goreng Jeruk Nipis | 25 | 2 | mudah
tag: hemat
desc: Ikan goreng renyah dengan perasan jeruk nipis dan bumbu bawang.
bahan:
- fish* | 2 ekor kecil
- lime* | 2 buah
- garlic | 3 siung
- salt | 1 sdt
- turmeric? | 1/2 ruas
- cooking_oil | untuk menggoreng
langkah:
1. Bersihkan ikan, lumuri perasan jeruk nipis dan garam, diamkan 10 menit.
2. Haluskan bawang putih dan kunyit, oleskan ke ikan.
3. Panaskan minyak banyak di wajan.
4. Goreng ikan sampai kedua sisi keemasan dan renyah.
5. Sajikan dengan irisan jeruk nipis.
tip: Keringkan ikan agar minyak tidak memercik.
alat: wajan, spatula, ulekan, pisau, talenan

## ikan-bakar-kecap-teflon | Ikan Bakar Kecap Teflon | 30 | 2 | mudah
tag: hemat
desc: Ikan bakar manis gurih tanpa arang.
bahan:
- fish* | 2 ekor kecil
- sweet_soy_sauce | 3 sdm
- garlic | 3 siung
- shallot | 3 siung
- lime | 1/2 buah
- salt | 1/2 sdt
- cooking_oil | 1 sdm
langkah:
1. Lumuri ikan dengan air jeruk nipis dan garam.
2. Haluskan bawang putih dan bawang merah, campur dengan kecap.
3. Panaskan teflon dengan minyak.
4. Panggang ikan tertutup dengan api kecil sambil dioles bumbu, balik setelah 5 menit.
5. Masak sampai matang dan bumbu mengering.
alat: teflon, penutup, kuas, ulekan, pisau, talenan

## ikan-asam-manis-nanas | Ikan Asam Manis Nanas | 30 | 3 | sedang
tag: segar
desc: Ikan goreng disiram saus asam manis dengan potongan nanas.
bahan:
- fish* | 400 g fillet
- pineapple* | 1/4 buah
- tomato | 1 buah
- bell_pepper? | 1/2 buah
- garlic | 2 siung
- vinegar | 1 sdm
- sugar | 2 sdm
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Lumuri ikan dengan garam, goreng sampai kuning keemasan.
2. Tumis bawang putih, lalu masukkan tomat, paprika, dan nanas.
3. Tambahkan cuka, gula, garam, dan sedikit air.
4. Masak 3 menit sampai saus agak kental.
5. Siram saus ke atas ikan.
alat: wajan, spatula, pisau, talenan

## udang-balado | Udang Balado | 25 | 3 | mudah
tag: pedas
desc: Udang goreng cepat dengan sambal balado merah.
bahan:
- shrimp* | 300 g
- chili* | 10 buah
- tomato | 1 buah
- shallot | 4 siung
- garlic | 2 siung
- sugar | 1 sdt
- salt | 1 sdt
- cooking_oil | 3 sdm
langkah:
1. Bersihkan udang, lumuri sedikit garam.
2. Haluskan cabai, tomat, bawang merah, dan bawang putih.
3. Tumis sambal sampai harum dan matang.
4. Masukkan udang, aduk sampai berwarna merah muda.
5. Bumbui gula dan garam, angkat saat bumbu meresap.
tip: Jangan masak udang terlalu lama agar tidak alot.
alat: wajan, spatula, ulekan, pisau, talenan

## udang-asam-manis | Udang Asam Manis | 20 | 2 | mudah
tag: segar, anak
desc: Udang berbalut saus tomat asam manis.
bahan:
- shrimp* | 250 g
- tomato* | 2 buah
- bell_pepper? | 1/2 buah
- garlic | 2 siung
- vinegar | 1 sdm
- sugar | 2 sdm
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Haluskan satu tomat, potong sisanya.
2. Tumis bawang putih, masukkan udang sampai berubah warna.
3. Tuang tomat halus, cuka, gula, dan garam.
4. Masukkan tomat potong dan paprika, masak 3 menit.
alat: wajan, spatula, blender, pisau, talenan

## kepiting-saus-padang | Kepiting Saus Padang | 35 | 3 | sedang
tag: pedas
desc: Kepiting dengan saus cabai kental yang pedas manis.
bahan:
- crab* | 2 ekor
- chili* | 10 buah
- tomato | 2 buah
- shallot | 5 siung
- garlic | 3 siung
- ginger | 1 ruas
- sugar | 1 sdm
- salt | 1 sdt
- cooking_oil | 3 sdm
langkah:
1. Bersihkan kepiting, potong menjadi beberapa bagian.
2. Haluskan cabai, tomat, bawang merah, bawang putih, dan jahe.
3. Tumis bumbu halus sampai harum dan matang.
4. Masukkan kepiting, aduk sampai merah.
5. Tambahkan sedikit air, gula, dan garam, masak tertutup 10 menit sampai matang.
alat: wajan, penutup, spatula, ulekan, pisau, talenan

## sosis-bakar-saus | Sosis Bakar Saus | 15 | 2 | mudah
tag: camilan, anak
desc: Sosis panggang dengan saus tomat pedas manis buatan sendiri.
bahan:
- sausage* | 4 buah
- tomato | 1 buah
- chili? | 2 buah
- garlic | 1 siung
- sugar | 1 sdt
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Tumis bawang putih, tomat potong, dan cabai sampai lunak, bumbui gula dan garam.
2. Haluskan menjadi saus.
3. Panggang sosis di teflon dengan sedikit minyak sampai kecokelatan.
4. Sajikan dengan saus.
alat: teflon, wajan, spatula, blender, pisau, talenan

## bakwan-jagung | Bakwan Jagung | 20 | 4 | mudah
tag: camilan, hemat, anak, vegetarian
desc: Gorengan jagung manis berbumbu bawang yang renyah.
bahan:
- corn* | 2 buah
- flour | 6 sdm
- spring_onion | 1 batang
- garlic | 2 siung
- egg? | 1 butir
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Serut jagung dari bonggolnya.
2. Campur jagung, tepung, telur, bawang putih halus, daun bawang, dan garam.
3. Tambahkan sedikit air, aduk sampai adonan kental.
4. Goreng satu sendok adonan demi satu dalam minyak panas sampai keemasan.
5. Tiriskan.
alat: wajan, spatula, mangkuk, pisau, talenan, saringan

## bakwan-sayur | Bakwan Sayur | 25 | 4 | mudah
tag: camilan, hemat, vegetarian
desc: Gorengan kol, wortel, dan tauge dalam adonan tepung.
bahan:
- cabbage* | 100 g
- carrot* | 1 buah
- flour | 8 sdm
- bean_sprout? | 1 genggam
- spring_onion | 1 batang
- garlic | 2 siung
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Iris kol dan wortel tipis memanjang.
2. Campur dengan tepung, bawang putih halus, daun bawang, garam, dan air sampai adonan kental.
3. Panaskan minyak banyak.
4. Goreng satu sendok adonan sampai keemasan dan renyah.
alat: wajan, spatula, mangkuk, pisau, talenan, saringan

## jus-alpukat-cokelat | Jus Alpukat Cokelat | 5 | 2 | mudah
tag: minuman, manis, tanpa-kompor, vegetarian
desc: Jus alpukat kental dengan saus cokelat.
bahan:
- avocado* | 1 buah matang
- chocolate | 2 sdm
- milk | 200 ml
- ice? | 4 kotak
- sugar? | 1 sdm
langkah:
1. Belah alpukat, ambil daging buahnya.
2. Masukkan alpukat, susu, gula, dan es batu ke blender.
3. Blender sampai halus.
4. Tuang ke gelas, beri cokelat leleh di dasar dan atasnya.
alat: blender, pisau, sendok, gelas
ganti: chocolate = bubuk kakao dan sedikit gula

## jus-wortel-apel | Jus Wortel Apel | 10 | 2 | mudah
tag: minuman, sehat, segar, tanpa-kompor, vegetarian
desc: Jus manis alami kaya warna dari wortel dan apel.
bahan:
- carrot* | 2 buah
- apple* | 2 buah
- lemon? | 1/2 buah
- water | 150 ml
- ice? | 4 kotak
langkah:
1. Kupas wortel, cuci apel, buang bijinya.
2. Potong kecil agar mudah diblender.
3. Blender bersama air dan perasan lemon.
4. Saring bila ingin lebih halus, sajikan dingin.
alat: blender, pisau, talenan, saringan, gelas

## jus-tomat-madu | Jus Tomat Madu | 5 | 2 | mudah
tag: minuman, segar, sehat, tanpa-kompor, vegetarian
desc: Jus tomat segar yang dimaniskan madu.
bahan:
- tomato* | 3 buah
- honey* | 2 sdm
- lemon? | 1/2 buah
- water | 150 ml
- ice? | 4 kotak
langkah:
1. Cuci dan potong tomat.
2. Blender bersama madu, air, dan perasan lemon.
3. Tambah es batu, sajikan segera.
alat: blender, pisau, talenan, gelas

## jus-pepaya-jeruk | Jus Pepaya Jeruk | 10 | 2 | mudah
tag: minuman, segar, sehat, tanpa-kompor, vegetarian
desc: Jus pepaya manis dengan sentuhan segar jeruk.
bahan:
- papaya* | 200 g
- orange* | 2 buah
- honey? | 1 sdt
- ice? | 4 kotak
langkah:
1. Kupas pepaya, buang bijinya, potong dadu.
2. Peras jeruk, saring bijinya.
3. Blender pepaya dengan air jeruk dan es batu.
4. Tuang segera ke gelas.
alat: blender, pisau, talenan, gelas

## asinan-buah | Asinan Buah | 20 | 3 | mudah
tag: segar, pedas, vegetarian, tanpa-kompor
desc: Buah segar dalam kuah asam manis pedas.
bahan:
- pineapple* | 1/4 buah
- cucumber* | 1 buah
- papaya | 150 g
- chili | 3 buah
- palm_sugar | 3 sdm
- vinegar | 2 sdm
- peanut? | 2 sdm
- salt | 1/2 sdt
langkah:
1. Potong nanas, mentimun, dan pepaya.
2. Haluskan cabai, gula merah, cuka, dan garam, tambah air sampai kuah encer.
3. Tuang kuah ke buah, dinginkan dulu di kulkas.
4. Taburi kacang tanah sebelum disajikan.
tip: Buah yang agak mengkal tetap renyah dalam kuah asam.
alat: ulekan, pisau, talenan, mangkuk

## pisang-epe-gula-merah | Pisang Epe Gula Merah | 20 | 2 | mudah
tag: camilan, manis, vegetarian
desc: Pisang pipih panggang disiram saus gula merah ala Makassar.
bahan:
- banana* | 4 buah pisang kepok
- palm_sugar | 4 sdm
- water | 100 ml
- salt | 1 sejumput
- butter? | 1 sdt
langkah:
1. Kupas pisang, pipihkan perlahan dengan dasar gelas.
2. Panggang di teflon dengan sedikit mentega sampai kecokelatan.
3. Rebus gula merah dengan air dan garam sampai agak kental.
4. Siramkan saus di atas pisang.
alat: teflon, panci kecil, spatula, gelas

## pisang-molen-teflon | Pisang Molen Teflon | 30 | 3 | sedang
tag: camilan, manis, anak, vegetarian
desc: Pisang berbalut kulit tepung tipis yang dimasak di teflon.
bahan:
- banana* | 3 buah
- flour | 150 g
- butter | 1 sdm
- sugar | 1 sdm
- salt | 1 sejumput
- water | 80 ml
langkah:
1. Campur tepung, gula, garam, dan mentega leleh, tambahkan air sampai adonan kalis.
2. Pipihkan tipis, bungkus potongan pisang.
3. Panaskan teflon dengan sedikit mentega.
4. Panggang dengan api kecil, balik sampai kedua sisi kecokelatan.
alat: teflon, spatula, mangkuk, pisau, talenan

## kolak-ubi | Kolak Ubi | 30 | 4 | mudah
tag: manis, berkuah, vegetarian
desc: Ubi jalar dalam kuah santan gula merah.
bahan:
- sweet_potato* | 3 buah
- coconut_milk | 400 ml
- palm_sugar | 100 g
- cinnamon? | 1 batang
- salt | 1 sejumput
- water | 400 ml
langkah:
1. Kupas ubi, potong dadu.
2. Rebus air dengan gula merah dan kayu manis sampai larut.
3. Masukkan ubi, masak sampai hampir empuk.
4. Tuang santan dan garam, aduk perlahan sampai matang.
alat: panci, sendok kayu, pisau, talenan

## bubur-kacang-hijau | Bubur Kacang Hijau | 60 | 4 | mudah
tag: manis, sarapan, vegetarian
desc: Bubur kacang hijau lembut dengan gula merah dan santan.
bahan:
- mung_bean* | 200 g
- coconut_milk | 200 ml
- palm_sugar | 100 g
- ginger | 1 ruas
- salt | 1 sejumput
- water | 1 liter
langkah:
1. Cuci kacang hijau, rendam 1 jam bila sempat.
2. Rebus dengan air dan jahe geprek sampai kacang pecah dan empuk.
3. Masukkan gula merah dan garam.
4. Tuang santan, aduk dan angkat sebelum mendidih keras.
alat: panci, sendok kayu, pisau

## es-teler-sederhana | Es Teler Sederhana | 15 | 2 | mudah
tag: minuman, manis, segar, tanpa-kompor, vegetarian
desc: Es buah dengan alpukat, kelapa, dan nangka dalam kuah susu.
bahan:
- avocado* | 1 buah
- coconut* | 1/2 butir muda
- milk* | 200 ml
- ice | 1 mangkuk
- sugar | 2 sdm
langkah:
1. Kerok daging kelapa muda, potong alpukat.
2. Larutkan gula dalam susu.
3. Tata buah di mangkuk.
4. Tuang susu manis dan beri es batu.
alat: pisau, sendok, mangkuk, talenan

## pancake-pisang | Pancake Pisang | 20 | 2 | mudah
tag: sarapan, manis, anak, vegetarian
desc: Pancake lembut dari pisang yang dilumatkan.
bahan:
- banana* | 2 buah
- flour | 100 g
- egg | 1 butir
- milk | 100 ml
- sugar? | 1 sdm
- butter | 1 sdt
langkah:
1. Lumatkan pisang dengan garpu, campur telur, susu, dan gula.
2. Masukkan tepung, aduk sampai adonan licin.
3. Panaskan teflon, olesi mentega.
4. Tuang satu sendok sayur adonan, masak sampai muncul gelembung, balik.
5. Masak sisi lainnya sampai kecokelatan.
alat: teflon, spatula, mangkuk, garpu

## roti-bakar-cokelat-keju | Roti Bakar Cokelat Keju | 10 | 2 | mudah
tag: sarapan, camilan, manis, anak, vegetarian
desc: Roti bakar dengan lelehan cokelat dan keju parut.
bahan:
- bread* | 4 lembar
- chocolate | 3 sdm
- cheese* | 40 g
- butter | 1 sdm
langkah:
1. Olesi satu sisi roti dengan mentega.
2. Olesi sisi lain dengan cokelat, taburi keju.
3. Tutup dengan roti lain.
4. Panggang di teflon api kecil sampai keju meleleh dan kecokelatan.
alat: teflon, spatula, parutan, pisau

## smoothie-stroberi-pisang | Smoothie Stroberi Pisang | 5 | 1 | mudah
tag: minuman, sarapan, manis, segar, tanpa-kompor, vegetarian
desc: Smoothie dua buah yang manis asam.
bahan:
- strawberry* | 6 buah
- banana* | 1 buah
- yogurt | 100 g
- milk? | 100 ml
- honey? | 1 sdt
langkah:
1. Cuci stroberi dan buang tangkainya.
2. Masukkan semua bahan ke blender.
3. Blender sampai halus dan kental.
alat: blender, pisau, gelas

## jus-nanas-segar | Jus Nanas Segar | 10 | 2 | mudah
tag: minuman, segar, manis, tanpa-kompor, vegetarian
desc: Jus nanas asam manis yang menyegarkan.
bahan:
- pineapple* | 1/2 buah
- lemon? | 1/2 buah
- honey? | 1 sdm
- water | 150 ml
- ice | 5 kotak
langkah:
1. Kupas nanas, buang mata dan bonggolnya, potong kecil.
2. Blender bersama air, madu, dan es batu.
3. Saring bila ingin lebih halus.
alat: blender, pisau, talenan, saringan, gelas

## infused-water-lemon-timun | Infused Water Lemon Timun | 5 | 4 | mudah
tag: minuman, segar, sehat, tanpa-kompor, vegetarian
desc: Air minum beraroma lemon, timun, dan mint.
bahan:
- lemon* | 1 buah
- cucumber* | 1/2 buah
- mint? | 6 lembar
- ice? | secukupnya
- water | 1 liter
langkah:
1. Iris tipis lemon dan mentimun.
2. Masukkan ke teko bersama daun mint.
3. Tuang air dingin, diamkan di kulkas 1 jam.
4. Sajikan dingin.
alat: teko, pisau, talenan

## wedang-jahe-serai | Wedang Jahe Serai | 15 | 3 | mudah
tag: minuman, sehat, vegetarian
desc: Minuman hangat jahe dan serai yang menenangkan.
bahan:
- ginger* | 2 ruas
- lemongrass | 2 batang
- palm_sugar | 2 sdm
- cinnamon? | 1 batang
- water | 600 ml
langkah:
1. Geprek jahe dan serai.
2. Rebus bersama kayu manis di air sampai mendidih dan harum, sekitar 10 menit.
3. Masukkan gula merah sampai larut.
4. Saring dan sajikan hangat.
alat: panci, saringan, gelas, pisau

## susu-jahe-hangat | Susu Jahe Hangat | 10 | 1 | mudah
tag: minuman, sehat, vegetarian
desc: Susu hangat beraroma jahe untuk malam yang dingin.
bahan:
- milk* | 250 ml
- ginger* | 1 ruas
- honey | 1 sdt
langkah:
1. Geprek jahe.
2. Panaskan susu bersama jahe dengan api kecil jangan sampai mendidih kencang.
3. Diamkan 3 menit supaya aroma keluar.
4. Saring, tambahkan madu.
alat: panci kecil, saringan, gelas

## spaghetti-carbonara-rumahan | Spaghetti Carbonara Rumahan | 25 | 2 | sedang
tag: sarapan
desc: Spaghetti dengan saus telur dan keju yang creamy tanpa krim.
bahan:
- pasta* | 200 g spaghetti
- egg* | 2 butir
- cheese* | 50 g
- sausage | 2 buah
- garlic | 2 siung
- pepper | 1/2 sdt
- salt | 1 sdt
langkah:
1. Rebus spaghetti dengan garam sampai al dente, sisakan 1/2 gelas air rebusannya.
2. Tumis sosis iris dan bawang putih sampai harum.
3. Kocok telur dengan keju parut dan merica.
4. Matikan api, masukkan spaghetti ke wajan, tuang campuran telur sambil diaduk cepat.
5. Tambahkan air rebusan bila perlu agar saus licin.
tip: Matikan api sebelum menuang telur agar tidak menggumpal.
alat: panci, wajan, spatula, parutan, mangkuk

## spaghetti-bolognese | Spaghetti Bolognese | 35 | 3 | mudah
tag: anak
desc: Spaghetti dengan saus daging dan tomat.
bahan:
- pasta* | 250 g spaghetti
- beef* | 200 g giling
- tomato* | 3 buah
- onion | 1 buah
- garlic | 3 siung
- sugar | 1 sdt
- salt | 1 sdt
- cooking_oil | 2 sdm
langkah:
1. Rebus spaghetti sampai al dente, tiriskan.
2. Tumis bawang bombay dan bawang putih sampai harum.
3. Masukkan daging, masak sampai berubah warna.
4. Tambahkan tomat cincang, gula, garam, dan sedikit air, masak 15 menit.
5. Sajikan saus di atas spaghetti.
alat: panci, wajan, spatula, pisau, talenan, saringan

## makaroni-schotel-kukus | Makaroni Schotel Kukus | 40 | 4 | sedang
tag: anak
desc: Makaroni panggang versi kukus dengan keju dan telur.
bahan:
- pasta* | 150 g makaroni
- cheese* | 80 g
- egg | 2 butir
- milk | 200 ml
- sausage? | 2 buah
- butter | 1 sdm
- salt | 1/2 sdt
- pepper | 1/4 sdt
langkah:
1. Rebus makaroni setengah matang, tiriskan.
2. Kocok telur dengan susu, sebagian keju, garam, dan merica.
3. Campur dengan makaroni dan sosis iris, tuang ke loyang berolesi mentega.
4. Kukus 25 menit sampai set.
5. Taburi sisa keju, kukus lagi 3 menit.
alat: panci, kukusan, loyang, mangkuk, parutan

## pizza-roti-tawar-teflon | Pizza Roti Tawar Teflon | 15 | 2 | mudah
tag: camilan, anak
desc: Pizza mini dari roti tawar yang dipanggang di teflon.
bahan:
- bread* | 4 lembar
- cheese* | 60 g
- tomato* | 2 buah
- sausage? | 2 buah
- bell_pepper? | 1/4 buah
- sugar | 1/2 sdt
- salt | 1/4 sdt
- butter | 1 sdt
langkah:
1. Cincang tomat lalu masak sebentar dengan gula dan garam jadi saus.
2. Olesi roti dengan saus, beri sosis, paprika, dan keju parut.
3. Panaskan teflon dengan mentega.
4. Letakkan roti, tutup, masak api kecil sampai keju meleleh dan dasar renyah.
alat: teflon, penutup, spatula, parutan, pisau, talenan

## bruschetta-tomat | Bruschetta Tomat | 10 | 2 | mudah
tag: camilan, segar, vegetarian
desc: Roti panggang renyah dengan topping tomat dan bawang putih.
bahan:
- bread* | 4 iris
- tomato* | 2 buah
- garlic | 1 siung
- mint? | 4 lembar
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Cincang tomat, campur dengan garam, minyak, dan daun mint cincang.
2. Panggang roti di teflon sampai renyah.
3. Gosok roti panas dengan bawang putih.
4. Letakkan campuran tomat dan sajikan segera.
alat: teflon, spatula, pisau, talenan, mangkuk

## sup-tomat | Sup Tomat | 25 | 3 | mudah
tag: berkuah, sehat, vegetarian
desc: Sup tomat halus beraroma bawang.
bahan:
- tomato* | 5 buah
- onion | 1/2 buah
- garlic | 2 siung
- butter | 1 sdm
- sugar | 1/2 sdt
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 400 ml
langkah:
1. Tumis bawang bombay dan bawang putih dengan mentega.
2. Masukkan tomat potong dan air, masak 15 menit sampai lunak.
3. Haluskan dengan blender.
4. Panaskan lagi, bumbui gula, garam, dan merica.
alat: panci, blender, sendok kayu, pisau, talenan

## ratatouille-sederhana | Ratatouille Sederhana | 35 | 3 | sedang
tag: sehat, vegetarian
desc: Rebusan sayur panggang ala Prancis dari terong, zukini, dan tomat.
bahan:
- zucchini* | 1 buah
- eggplant* | 1 buah
- tomato* | 3 buah
- bell_pepper | 1/2 buah
- onion | 1/2 buah
- garlic | 2 siung
- salt | 1 sdt
- cooking_oil | 3 sdm
langkah:
1. Potong semua sayur dadu sama besar.
2. Tumis bawang bombay dan bawang putih.
3. Masukkan terong dan paprika, masak 5 menit.
4. Masukkan zukini dan tomat, tutup dan masak api kecil 15 menit.
5. Bumbui garam dan masak sampai sayur empuk.
alat: wajan, penutup, spatula, pisau, talenan

## kentang-tumbuk-mentega | Kentang Tumbuk Mentega | 30 | 3 | mudah
tag: anak, vegetarian
desc: Kentang lembut dilumatkan dengan mentega dan susu.
bahan:
- potato* | 3 buah
- butter* | 2 sdm
- milk | 100 ml
- salt | 1/2 sdt
- pepper | 1/4 sdt
langkah:
1. Kupas kentang, potong dadu, rebus sampai sangat empuk.
2. Tiriskan dan lumatkan selagi panas.
3. Tambahkan mentega dan susu hangat sedikit demi sedikit.
4. Bumbui garam dan merica, aduk sampai halus.
alat: panci, saringan, garpu, pisau, talenan

## kentang-panggang-keju | Kentang Panggang Keju | 50 | 3 | mudah
tag: camilan, vegetarian
desc: Kentang panggang renyah dengan keju meleleh.
bahan:
- potato* | 4 buah
- cheese* | 60 g
- butter | 1 sdm
- salt | 1/2 sdt
- pepper | 1/4 sdt
langkah:
1. Panaskan oven 200 derajat Celsius.
2. Belah kentang, olesi mentega, garam, dan merica.
3. Panggang 35 menit sampai empuk dan kecokelatan.
4. Taburi keju parut, panggang lagi 5 menit.
alat: oven, loyang, parutan, pisau, talenan

## salad-caprese | Salad Caprese | 10 | 2 | mudah
tag: segar, vegetarian, tanpa-kompor
desc: Tomat dan keju dengan daun mint dan minyak.
bahan:
- tomato* | 3 buah
- cheese* | 100 g
- mint | 6 lembar
- cooking_oil | 1 sdm
- salt | 1/4 sdt
- pepper | sedikit
langkah:
1. Iris tomat dan keju tipis.
2. Tata bergantian di piring.
3. Sisipkan daun mint, tuang minyak, taburi garam dan merica.
alat: pisau, talenan, piring

## coleslaw-yoghurt | Coleslaw Yoghurt | 15 | 3 | mudah
tag: segar, sehat, vegetarian, tanpa-kompor
desc: Salad kol dan wortel dengan saus yoghurt ringan.
bahan:
- cabbage* | 200 g
- carrot* | 1 buah
- yogurt | 4 sdm
- lemon | 1/2 buah
- honey? | 1 sdt
- salt | 1/2 sdt
- pepper | sedikit
langkah:
1. Iris kol tipis dan parut wortel.
2. Campur yoghurt, perasan lemon, madu, garam, dan merica.
3. Aduk sayur dengan saus.
4. Dinginkan 15 menit sebelum disajikan.
alat: pisau, talenan, parutan, mangkuk

## asparagus-panggang-mentega | Asparagus Panggang Mentega | 15 | 2 | mudah
tag: sehat, vegetarian
desc: Asparagus panggang cepat dengan mentega dan bawang putih.
bahan:
- asparagus* | 1 ikat
- butter* | 1 sdm
- garlic | 2 siung
- lemon? | 1/2 buah
- salt | 1/4 sdt
- pepper | sedikit
langkah:
1. Patahkan ujung keras asparagus.
2. Leleh mentega di teflon, tumis bawang putih sebentar.
3. Masukkan asparagus, masak 5 menit sambil dibalik sampai agak kecokelatan.
4. Bumbui garam, merica, dan perasan lemon.
alat: teflon, spatula, pisau, talenan

## acar-lobak-wortel | Acar Lobak Wortel | 20 | 4 | mudah
tag: segar, sehat, vegetarian
desc: Lobak dan wortel dalam kuah cuka manis.
bahan:
- radish* | 1 buah
- carrot* | 1 buah
- vinegar | 4 sdm
- sugar | 3 sdm
- chili? | 2 buah
- salt | 1 sdt
- water | 100 ml
langkah:
1. Iris lobak dan wortel tipis batang.
2. Panaskan cuka, gula, garam, dan air sampai larut.
3. Dinginkan kuah, tuang ke sayur.
4. Simpan di kulkas minimal 1 jam.
alat: panci kecil, toples, pisau, talenan

## salad-jeruk-mentimun | Salad Jeruk Mentimun | 10 | 2 | mudah
tag: segar, sehat, vegetarian, tanpa-kompor
desc: Jeruk dan mentimun dengan perasan lemon.
bahan:
- orange* | 2 buah
- cucumber* | 1 buah
- lemon | 1/2 buah
- honey? | 1 sdt
- mint? | 4 lembar
- salt | 1 sejumput
langkah:
1. Kupas jeruk dan potong per segmen.
2. Iris tipis mentimun.
3. Campur dengan perasan lemon, madu, dan garam.
4. Taburi daun mint, dinginkan sebentar.
alat: pisau, talenan, mangkuk

## selai-stroberi | Selai Stroberi | 30 | 6 | mudah
tag: manis, vegetarian
desc: Selai stroberi dengan rasa asam manis alami.
bahan:
- strawberry* | 300 g
- sugar | 100 g
- lemon | 1/2 buah
langkah:
1. Cuci stroberi, buang tangkai, potong kecil.
2. Masak bersama gula di panci api kecil sampai keluar air.
3. Tambahkan perasan lemon.
4. Masak sambil diaduk 20 menit sampai kental.
5. Dinginkan, simpan dalam toples bersih.
tip: Selai akan lebih kental setelah dingin.
alat: panci, sendok kayu, toples, pisau, talenan

## kompot-pir-jahe | Kompot Pir Jahe | 25 | 3 | mudah
tag: manis, minuman, vegetarian
desc: Pir rebus dalam sirup jahe hangat.
bahan:
- pear* | 3 buah
- ginger* | 1 ruas
- sugar | 3 sdm
- cinnamon? | 1 batang
- water | 400 ml
langkah:
1. Kupas pir, potong 4 bagian.
2. Rebus air, gula, jahe geprek, dan kayu manis.
3. Masukkan pir, masak api kecil 15 menit sampai empuk.
4. Sajikan hangat atau dingin.
alat: panci, sendok kayu, pisau, talenan

## persik-panggang-madu-yoghurt | Persik Panggang Madu Yoghurt | 20 | 2 | mudah
tag: manis, sehat, vegetarian
desc: Persik hangat dengan yoghurt dingin dan madu.
bahan:
- peach* | 2 buah
- yogurt* | 100 g
- honey | 2 sdm
- butter? | 1 sdt
langkah:
1. Belah persik, buang bijinya.
2. Panggang di teflon dengan mentega, sisi potong menghadap bawah, 5 menit.
3. Balik, olesi madu, masak 3 menit.
4. Sajikan dengan yoghurt.
alat: teflon, spatula, pisau, talenan

## smoothie-melon-kelapa | Smoothie Melon Kelapa | 10 | 2 | mudah
tag: minuman, segar, manis, tanpa-kompor, vegetarian
desc: Smoothie melon dengan air kelapa dan daging kelapa muda.
bahan:
- cantaloupe* | 300 g
- coconut* | 1 butir muda
- ice? | 5 kotak
- honey? | 1 sdt
langkah:
1. Potong melon, kerok daging kelapa muda.
2. Masukkan melon, daging kelapa, dan air kelapa ke blender.
3. Tambah es dan madu.
4. Blender sampai halus.
alat: blender, pisau, sendok, gelas

## salad-buah-tin-keju-madu | Salad Buah Tin Keju Madu | 10 | 2 | mudah
tag: segar, camilan, vegetarian, tanpa-kompor
desc: Buah tin segar dengan keju dan madu.
bahan:
- fig* | 4 buah
- cheese* | 50 g
- honey | 1 sdm
- lettuce? | 3 lembar
- lemon? | sedikit
langkah:
1. Belah buah tin menjadi empat.
2. Alasi piring dengan selada.
3. Letakkan buah tin dan keju potong dadu.
4. Siram madu dan perasan lemon.
alat: pisau, talenan, piring

## es-kundur-gula-merah | Es Kundur Gula Merah | 40 | 4 | mudah
tag: minuman, manis, segar, vegetarian
desc: Kundur dalam sirup gula merah dingin.
bahan:
- winter_melon* | 300 g
- palm_sugar | 100 g
- ice | 1 mangkuk
- water | 600 ml
langkah:
1. Kupas kundur, potong dadu kecil.
2. Rebus gula merah dengan air sampai larut, saring.
3. Masukkan kundur, masak sampai bening dan empuk.
4. Dinginkan, tuang ke gelas dengan es batu.
alat: panci, saringan, pisau, talenan, gelas

## sayur-labu-siam-santan-udang | Sayur Labu Siam Santan Udang | 30 | 4 | sedang
tag: berkuah
desc: Labu siam dengan udang dalam kuah santan bumbu kuning.
bahan:
- squash* | 2 buah
- shrimp* | 150 g
- coconut_milk | 300 ml
- shallot | 4 siung
- garlic | 2 siung
- turmeric | 1 ruas
- lemongrass | 1 batang
- salt | 1 sdt
- cooking_oil | 2 sdm
langkah:
1. Haluskan bawang merah, bawang putih, dan kunyit.
2. Tumis bumbu dengan serai sampai harum.
3. Masukkan udang sampai berubah warna.
4. Masukkan labu siam potong, air sedikit, masak 5 menit.
5. Tuang santan, masak api kecil sampai labu empuk, bumbui garam.
alat: panci, wajan, ulekan, pisau, talenan, sendok sayur

## sup-kepiting-jagung | Sup Kepiting Jagung | 30 | 3 | sedang
tag: berkuah
desc: Sup kental jagung dengan daging kepiting dan telur.
bahan:
- crab* | 1 ekor atau 150 g daging
- corn* | 2 buah
- egg | 1 butir
- ginger | 1 ruas
- garlic | 2 siung
- spring_onion | 1 batang
- flour | 1 sdm
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 700 ml
langkah:
1. Rebus kepiting sampai matang, ambil dagingnya.
2. Tumis bawang putih dan jahe, tuang air dan jagung serut.
3. Didihkan 10 menit, kentalkan dengan larutan tepung.
4. Masukkan daging kepiting, bumbui garam dan merica.
5. Tuang telur kocok perlahan, taburi daun bawang.
alat: panci, wajan, sendok kayu, mangkuk, pisau, talenan

## roti-goreng-isi-telur | Roti Goreng Isi Telur | 15 | 2 | mudah
tag: sarapan, camilan, anak
desc: Roti tawar berisi telur orak-arik yang digoreng.
bahan:
- bread* | 4 lembar
- egg* | 3 butir
- spring_onion? | 1 batang
- salt | 1/4 sdt
- cooking_oil | secukupnya
langkah:
1. Kocok 2 butir telur dengan garam dan daun bawang, orak-arik hingga matang.
2. Pipihkan roti, isi dengan telur orak-arik, lipat dan rapatkan tepinya.
3. Kocok satu butir telur untuk perekat dan pelapis.
4. Goreng sampai kecokelatan.
alat: wajan, spatula, mangkuk, garpu, pisau

## jus-delima-apel | Jus Delima Apel | 10 | 2 | mudah
tag: minuman, segar, sehat, tanpa-kompor, vegetarian
desc: Jus merah segar dengan rasa manis asam.
bahan:
- pomegranate* | 1 buah
- apple* | 1 buah
- honey? | 1 sdt
- ice? | 4 kotak
langkah:
1. Ambil bulir delima, potong apel dan buang bijinya.
2. Blender bersama es batu.
3. Saring agar tidak ada ampas biji bila perlu.
alat: blender, pisau, talenan, saringan, gelas

## smoothie-mangga-yoghurt | Smoothie Mangga Yoghurt | 5 | 1 | mudah
tag: minuman, sarapan, segar, manis, tanpa-kompor, vegetarian
desc: Smoothie mangga kental dengan yoghurt.
bahan:
- mango* | 1 buah matang
- yogurt* | 150 g
- honey? | 1 sdt
- ice? | 4 kotak
langkah:
1. Kupas mangga, ambil dagingnya.
2. Masukkan ke blender bersama yoghurt dan es batu.
3. Blender sampai halus.
alat: blender, pisau, gelas

## tumis-zukini-jamur | Tumis Zukini Jamur | 15 | 2 | mudah
tag: sehat, vegetarian
desc: Zukini dan jamur tumis cepat dengan bawang putih.
bahan:
- zucchini* | 1 buah
- mushroom* | 150 g
- garlic | 3 siung
- oyster_sauce | 1 sdm
- salt | 1/4 sdt
- pepper | sedikit
- cooking_oil | 2 sdm
langkah:
1. Iris zukini setengah bulan dan jamur tebal.
2. Tumis bawang putih sampai harum.
3. Masukkan jamur, masak sampai airnya keluar, lalu zukini.
4. Bumbui saus tiram, garam, dan merica, angkat saat zukini masih agak renyah.
alat: wajan, spatula, pisau, talenan

## sup-kentang-wortel-krim | Sup Kentang Wortel Krim | 35 | 4 | mudah
tag: berkuah, anak, vegetarian
desc: Sup kental halus dari kentang dan wortel dengan susu.
bahan:
- potato* | 2 buah
- carrot* | 2 buah
- milk | 300 ml
- onion | 1/2 buah
- butter | 1 sdm
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 400 ml
langkah:
1. Potong kentang dan wortel dadu.
2. Tumis bawang bombay dengan mentega, tambahkan sayur dan air.
3. Rebus sampai sangat empuk, haluskan dengan blender.
4. Panaskan lagi dengan susu, bumbui garam dan merica.
alat: panci, blender, sendok kayu, pisau, talenan

## semangka-mint-segar | Semangka Mint Segar | 5 | 2 | mudah
tag: minuman, segar, manis, tanpa-kompor, vegetarian
desc: Semangka dingin dengan daun mint dan lemon.
bahan:
- watermelon* | 400 g
- mint | 8 lembar
- lemon | 1/2 buah
- ice | 5 kotak
langkah:
1. Potong semangka, buang bijinya.
2. Blender semangka dengan setengah daun mint.
3. Tambah perasan lemon dan es batu.
4. Hias dengan sisa daun mint.
alat: blender, pisau, talenan, gelas

## pir-panggang-kayu-manis | Pir Panggang Kayu Manis | 35 | 2 | mudah
tag: manis, vegetarian
desc: Pir panggang harum kayu manis dan madu.
bahan:
- pear* | 2 buah
- cinnamon | 1 sdt bubuk
- honey | 2 sdm
- butter | 1 sdt
langkah:
1. Panaskan oven 180 derajat Celsius.
2. Belah pir, buang bijinya.
3. Olesi mentega, madu, dan kayu manis.
4. Panggang 25 menit sampai empuk.
alat: oven, loyang, pisau, talenan

## jus-anggur-lemon | Jus Anggur Lemon | 5 | 2 | mudah
tag: minuman, segar, manis, tanpa-kompor, vegetarian
desc: Jus anggur dingin dengan perasan lemon.
bahan:
- grape* | 2 genggam
- lemon* | 1/2 buah
- honey? | 1 sdt
- ice | 5 kotak
- water | 100 ml
langkah:
1. Cuci anggur, lepaskan dari tangkainya.
2. Blender bersama air, madu, dan es batu.
3. Saring bila ingin bebas kulit, tambahkan perasan lemon.
alat: blender, saringan, pisau, gelas

## persik-es-lemon | Es Persik Lemon | 10 | 2 | mudah
tag: minuman, segar, manis, tanpa-kompor, vegetarian
desc: Minuman persik dingin dengan irisan lemon.
bahan:
- peach* | 2 buah
- lemon* | 1/2 buah
- sugar | 1 sdm
- ice | 5 kotak
- water | 200 ml
langkah:
1. Belah persik, buang bijinya, potong kecil.
2. Blender dengan air dan gula.
3. Tuang ke gelas dengan es batu.
4. Tambahkan perasan lemon.
alat: blender, pisau, talenan, gelas

## salad-delima-jeruk | Salad Delima Jeruk | 10 | 2 | mudah
tag: segar, sehat, vegetarian, tanpa-kompor
desc: Salad segar jeruk, delima, dan selada.
bahan:
- pomegranate* | 1/2 buah
- orange* | 2 buah
- lettuce | 4 lembar
- honey | 1 sdt
- lemon? | sedikit perasan
langkah:
1. Kupas jeruk, potong segmen.
2. Ambil bulir delima.
3. Sobek selada, tata bersama jeruk di piring.
4. Taburi delima, siram madu dan lemon.
alat: pisau, talenan, mangkuk, piring

## es-jeruk-bali-madu | Es Jeruk Bali Madu | 10 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Minuman jeruk bali yang sedikit pahit dengan madu.
bahan:
- grapefruit* | 1 buah
- honey* | 2 sdm
- ice | 5 kotak
- water | 150 ml
langkah:
1. Kupas jeruk bali, ambil buah tanpa kulit putihnya.
2. Peras atau blender sebentar dengan air.
3. Campur madu, tuang ke gelas dengan es batu.
alat: pisau, talenan, gelas, sendok

## salad-jeruk-bali-alpukat | Salad Jeruk Bali Alpukat | 10 | 2 | mudah
tag: segar, sehat, vegetarian, tanpa-kompor
desc: Jeruk bali dan alpukat yang saling mengimbangi rasa.
bahan:
- grapefruit* | 1 buah
- avocado* | 1 buah
- lettuce | 4 lembar
- lemon | 1/2 buah
- honey? | 1 sdt
- salt | 1 sejumput
langkah:
1. Kupas jeruk bali dan potong segmen.
2. Potong alpukat.
3. Tata bersama selada di piring.
4. Siram campuran lemon, madu, dan garam.
alat: pisau, talenan, mangkuk, piring

## buah-tin-panggang-madu | Buah Tin Panggang Madu | 15 | 2 | mudah
tag: manis, vegetarian
desc: Buah tin hangat dengan madu dan keju.
bahan:
- fig* | 6 buah
- honey* | 2 sdm
- cheese? | 40 g
- butter | 1 sdt
langkah:
1. Belah buah tin menjadi dua.
2. Panggang di teflon dengan mentega 3 menit tiap sisi.
3. Siram madu, taburi keju.
alat: teflon, spatula, pisau, talenan

## tumis-brokoli-bawang-putih | Tumis Brokoli Bawang Putih | 12 | 2 | mudah
tag: sehat, vegetarian
desc: Brokoli tumis cepat dengan bawang putih.
bahan:
- broccoli* | 1 buah
- garlic* | 4 siung
- oyster_sauce | 1 sdm
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Potong brokoli kuntum kecil, rebus 1 menit lalu tiriskan.
2. Tumis bawang putih cincang.
3. Masukkan brokoli, saus tiram, dan garam.
4. Masak 2 menit.
alat: panci, wajan, spatula, saringan, pisau, talenan

## paprika-isi-telur | Paprika Isi Telur | 25 | 2 | mudah
tag: sarapan, sehat
desc: Paprika panggang berisi telur dan keju.
bahan:
- bell_pepper* | 2 buah
- egg* | 2 butir
- cheese | 30 g
- salt | 1/4 sdt
- pepper | sedikit
langkah:
1. Panaskan oven 180 derajat Celsius, potong paprika bagian atasnya dan buang bijinya.
2. Pecahkan telur ke dalam tiap paprika.
3. Bumbui garam dan merica, taburi keju.
4. Panggang 15 sampai 20 menit sampai telur matang.
alat: oven, loyang, parutan, pisau, talenan

## bubur-labu-kuning | Bubur Labu Kuning | 30 | 3 | mudah
tag: sarapan, anak, vegetarian, manis
desc: Bubur lembut labu kuning dengan santan.
bahan:
- pumpkin* | 300 g
- coconut_milk | 200 ml
- palm_sugar | 50 g
- salt | 1 sejumput
- water | 300 ml
langkah:
1. Kupas labu, potong dadu.
2. Rebus dengan air sampai empuk, lumatkan.
3. Masukkan gula merah dan garam.
4. Tuang santan, masak sebentar sambil diaduk.
alat: panci, sendok kayu, garpu, pisau, talenan

## kundur-sirup-jahe | Kundur Sirup Jahe | 30 | 3 | mudah
tag: minuman, manis, vegetarian
desc: Kundur rebus dalam sirup jahe yang hangat.
bahan:
- winter_melon* | 300 g
- ginger* | 1 ruas
- sugar | 3 sdm
- water | 500 ml
langkah:
1. Kupas kundur, potong dadu.
2. Rebus air dengan gula dan jahe geprek.
3. Masukkan kundur, masak sampai bening.
4. Sajikan hangat atau dingin.
alat: panci, pisau, talenan, sendok kayu

## lobak-tumis-telur | Lobak Tumis Telur | 15 | 2 | mudah
tag: hemat
desc: Lobak parut tumis dengan telur orak-arik.
bahan:
- radish* | 1 buah
- egg* | 2 butir
- spring_onion | 1 batang
- garlic | 2 siung
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Parut kasar lobak, peras ringan.
2. Tumis bawang putih, masukkan lobak, masak 3 menit.
3. Masukkan telur, orak-arik.
4. Bumbui garam, taburi daun bawang.
alat: wajan, spatula, parutan, pisau, talenan

## asparagus-telur-orak-arik | Asparagus Telur Orak-Arik | 12 | 2 | mudah
tag: sarapan, sehat
desc: Asparagus renyah dengan telur lembut.
bahan:
- asparagus* | 1 ikat
- egg* | 3 butir
- butter | 1 sdt
- salt | 1/4 sdt
- pepper | sedikit
langkah:
1. Potong asparagus 3 cm.
2. Tumis dengan mentega 3 menit.
3. Kocok telur dengan garam dan merica, tuang ke wajan.
4. Aduk sampai matang lembut.
alat: wajan, spatula, mangkuk, garpu, pisau, talenan

## artichoke-panggang-keju | Artichoke Panggang Keju | 40 | 2 | sedang
tag: sehat, vegetarian
desc: Artichoke dikukus lalu dipanggang dengan keju dan bawang putih.
bahan:
- artichoke* | 2 buah
- cheese* | 50 g
- garlic | 2 siung
- lemon | 1/2 buah
- butter | 1 sdm
- salt | 1/2 sdt
langkah:
1. Potong ujung kelopak artichoke, kukus 25 menit sampai empuk.
2. Panaskan oven 180 derajat Celsius.
3. Campur mentega, bawang putih halus, perasan lemon, dan garam.
4. Sisipkan campuran dan keju di antara kelopak.
5. Panggang 8 menit sampai keju meleleh.
alat: kukusan, oven, loyang, parutan, pisau, talenan

## salad-artichoke-tomat | Salad Artichoke Tomat | 20 | 2 | mudah
tag: segar, sehat, vegetarian
desc: Hati artichoke rebus dengan tomat dan selada.
bahan:
- artichoke* | 2 buah
- tomato* | 2 buah
- lettuce | 4 lembar
- lemon | 1/2 buah
- cooking_oil | 1 sdm
- salt | 1/4 sdt
langkah:
1. Rebus artichoke 20 menit sampai empuk, ambil hatinya, iris.
2. Potong tomat dan sobek selada.
3. Campur semua di mangkuk.
4. Siram perasan lemon, minyak, dan garam.
alat: panci, pisau, talenan, mangkuk

## es-durian | Es Durian | 10 | 2 | mudah
tag: minuman, manis, segar, tanpa-kompor, vegetarian
desc: Daging durian dengan santan dingin dan susu, disajikan dengan es serut.
bahan:
- durian* | 200 g daging buah
- coconut_milk | 150 ml
- milk | 100 ml
- sugar? | 1 sdm
- ice | 1 mangkuk
langkah:
1. Pisahkan daging durian dari bijinya.
2. Aduk santan, susu, dan gula sampai gula larut.
3. Tata es di gelas, beri daging durian di atasnya.
4. Siram dengan campuran santan dan susu, sajikan segera.
tip: Pakai santan yang sudah direbus lalu didinginkan agar tidak cepat basi.
alat: mangkuk, sendok, gelas

## jus-buah-naga | Jus Buah Naga | 5 | 2 | mudah
tag: minuman, sarapan, segar, tanpa-kompor, vegetarian
desc: Jus buah naga yang berwarna cerah, cukup diblender dengan susu atau air.
bahan:
- dragon_fruit* | 1 buah
- milk? | 150 ml
- honey? | 1 sdm
- ice | 4 kotak
- water | 100 ml
langkah:
1. Belah buah naga, kerok dagingnya.
2. Masukkan daging buah, air, susu, dan madu ke blender.
3. Blender sampai halus, tambahkan es batu, lalu tuang ke gelas.
tip: Buah naga berdaging merah membuat warna jus lebih pekat.
alat: blender, pisau, sendok, gelas

## salad-buah-naga-yoghurt | Salad Buah Naga Yoghurt | 10 | 2 | mudah
tag: sarapan, camilan, segar, tanpa-kompor, vegetarian
desc: Potongan buah naga dengan yoghurt dan madu.
bahan:
- dragon_fruit* | 1 buah
- yogurt* | 200 g
- kiwi? | 1 buah
- blueberry? | 50 g
- honey | 1 sdm
langkah:
1. Potong dadu buah naga dan kiwi.
2. Tuang yoghurt ke mangkuk.
3. Tata buah di atasnya, siram madu.
alat: pisau, talenan, mangkuk

## es-rambutan-kelapa | Es Rambutan Kelapa | 15 | 2 | mudah
tag: minuman, manis, segar, tanpa-kompor, vegetarian
desc: Rambutan kupas dengan kelapa muda dan air gula dingin.
bahan:
- rambutan* | 10 buah
- coconut | 1/2 butir muda
- sugar | 2 sdm
- water | 300 ml
- ice | 1 mangkuk
langkah:
1. Kupas rambutan dan buang bijinya.
2. Kerok daging kelapa muda.
3. Larutkan gula dalam air.
4. Tata rambutan, kelapa, dan es di gelas, lalu tuang air gula.
alat: pisau, sendok, gelas

## es-leci-mint | Es Leci Mint | 10 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Minuman leci dengan jeruk nipis dan daun mint.
bahan:
- lychee* | 12 buah
- mint | 6 lembar
- lime | 1 buah
- sugar | 1 sdm
- water | 300 ml
- ice | 1 mangkuk
langkah:
1. Kupas leci dan buang bijinya.
2. Remas daun mint bersama gula di gelas.
3. Masukkan leci, perasan jeruk nipis, air, dan es batu, lalu aduk.
alat: pisau, gelas, sendok

## es-kelengkeng | Es Kelengkeng | 10 | 2 | mudah
tag: minuman, manis, segar, tanpa-kompor, vegetarian
desc: Kelengkeng segar dalam air gula dingin.
bahan:
- longan* | 20 buah
- sugar | 2 sdm
- lime? | 1/2 buah
- water | 300 ml
- ice | 1 mangkuk
langkah:
1. Kupas kelengkeng dan buang bijinya.
2. Larutkan gula dalam air, beri perasan jeruk nipis.
3. Masukkan kelengkeng dan es batu ke gelas, tuang air gula.
alat: pisau, gelas, sendok

## rujak-serut-jambu-air | Rujak Jambu Air | 15 | 2 | mudah
tag: camilan, pedas, segar, tanpa-kompor, vegetarian
desc: Jambu air dengan sambal gula merah dan asam jawa.
bahan:
- rose_apple* | 6 buah
- mango? | 1 buah muda
- palm_sugar | 50 g
- tamarind | 1 sdt
- chili | 2 buah
- salt | 1/4 sdt
langkah:
1. Potong jambu air dan mangga.
2. Ulek cabai, gula merah, asam jawa, dan garam sampai halus.
3. Tambahkan sedikit air bila sambal terlalu kental.
4. Sajikan buah dengan sambal.
alat: pisau, talenan, cobek

## jus-jambu-biji | Jus Jambu Biji | 10 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Jus jambu biji merah yang kental.
bahan:
- guava* | 2 buah
- sugar | 2 sdm
- water | 250 ml
- ice | 4 kotak
langkah:
1. Cuci jambu, potong-potong.
2. Blender bersama air dan gula sampai halus.
3. Saring bila ingin bebas biji, lalu tambahkan es batu.
alat: blender, pisau, saringan, gelas

## jus-sirsak | Jus Sirsak | 10 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Jus sirsak asam manis yang menyegarkan.
bahan:
- soursop* | 300 g daging buah
- milk? | 100 ml
- sugar | 2 sdm
- water | 200 ml
- ice | 4 kotak
langkah:
1. Buang biji sirsak.
2. Blender daging buah dengan air, susu, dan gula.
3. Tambahkan es batu dan sajikan.
alat: blender, sendok, gelas

## salad-manggis-leci | Salad Manggis Leci | 10 | 2 | mudah
tag: camilan, segar, tanpa-kompor, vegetarian
desc: Daging buah manggis dan leci dengan yoghurt.
bahan:
- mangosteen* | 6 buah
- lychee? | 6 buah
- yogurt | 150 g
- honey? | 1 sdt
langkah:
1. Belah kulit manggis dengan menekannya, ambil daging buahnya.
2. Kupas leci dan buang bijinya.
3. Tata buah di mangkuk, beri yoghurt dan madu.
alat: pisau, mangkuk, sendok

## kolak-nangka-ubi | Kolak Nangka Ubi | 30 | 4 | mudah
tag: manis, berkuah, vegetarian
desc: Kolak ubi dengan potongan nangka dan santan gula merah.
bahan:
- jackfruit* | 150 g
- sweet_potato | 2 buah
- coconut_milk | 400 ml
- palm_sugar | 100 g
- pandan? | 2 lembar
- salt | 1/4 sdt
langkah:
1. Kupas ubi, potong dadu. Potong nangka memanjang.
2. Rebus ubi dengan gula merah dan pandan dalam 300 ml air sampai empuk.
3. Masukkan santan, nangka, dan garam.
4. Masak sambil diaduk sampai mendidih, lalu angkat.
alat: panci, pisau, talenan, sendok sayur

## asinan-salak | Asinan Salak | 20 | 4 | mudah
tag: camilan, segar, pedas, vegetarian
desc: Salak dalam kuah cuka manis pedas.
bahan:
- salak* | 10 buah
- chili | 3 buah
- sugar | 100 g
- vinegar | 2 sdm
- salt | 1 sdt
- water | 400 ml
langkah:
1. Kupas salak, belah dua, buang bijinya.
2. Rebus air, gula, garam, dan cabai sampai gula larut, lalu dinginkan.
3. Tambahkan cuka ke kuah.
4. Rendam salak dalam kuah di kulkas minimal 2 jam.
alat: panci, pisau, toples

## jus-belimbing-madu | Jus Belimbing Madu | 5 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Jus belimbing manis dengan madu.
bahan:
- starfruit* | 2 buah
- honey | 2 sdm
- water | 250 ml
- ice | 4 kotak
langkah:
1. Potong belimbing, buang bagian tepinya yang keras.
2. Blender bersama air dan madu sampai halus.
3. Saring, lalu tambahkan es batu.
alat: blender, pisau, saringan, gelas

## salad-buah-duku-melon | Salad Duku Melon | 10 | 2 | mudah
tag: camilan, segar, tanpa-kompor, vegetarian
desc: Duku kupas dan melon dengan yoghurt madu.
bahan:
- langsat* | 15 buah
- cantaloupe? | 1/4 buah
- yogurt | 150 g
- honey | 1 sdm
langkah:
1. Kupas duku dan buang bijinya.
2. Potong dadu melon.
3. Campur buah, beri yoghurt dan madu.
alat: pisau, talenan, mangkuk

## jus-sawo-susu | Jus Sawo Susu | 5 | 2 | mudah
tag: minuman, manis, tanpa-kompor, vegetarian
desc: Jus sawo matang yang manis dengan susu.
bahan:
- sapodilla* | 3 buah
- milk* | 200 ml
- ice | 4 kotak
langkah:
1. Kupas sawo dan buang bijinya.
2. Blender bersama susu sampai halus.
3. Tambahkan es batu dan sajikan.
alat: blender, pisau, gelas

## tumis-pepaya-muda | Tumis Pepaya Muda | 25 | 3 | mudah
tag: hemat, vegetarian
desc: Pepaya muda serut yang ditumis dengan bawang dan cabai.
bahan:
- papaya* | 1/2 buah muda
- shallot | 4 siung
- garlic | 2 siung
- chili | 3 buah
- bay_leaf? | 2 lembar
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Kupas pepaya muda, serut tipis, remas dengan sedikit garam, lalu bilas.
2. Tumis bawang merah, bawang putih, cabai, dan daun salam sampai harum.
3. Masukkan pepaya dan 50 ml air, masak sampai layu.
4. Bumbui garam dan angkat.
alat: wajan, spatula, parutan, pisau

## es-markisa | Es Markisa | 10 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Minuman markisa asam manis dengan bijinya.
bahan:
- passion_fruit* | 4 buah
- sugar | 3 sdm
- water | 400 ml
- ice | 1 mangkuk
langkah:
1. Belah markisa, kerok isinya ke wadah.
2. Larutkan gula dalam air.
3. Campur isi markisa dengan air gula, tambahkan es batu.
alat: pisau, sendok, gelas

## smoothie-kiwi-pisang | Smoothie Kiwi Pisang | 5 | 1 | mudah
tag: minuman, sarapan, segar, tanpa-kompor, vegetarian
desc: Smoothie hijau dari kiwi dan pisang.
bahan:
- kiwi* | 2 buah
- banana* | 1 buah
- yogurt | 100 g
- honey? | 1 sdt
langkah:
1. Kupas kiwi dan pisang, potong-potong.
2. Blender bersama yoghurt dan madu sampai halus.
alat: blender, pisau, gelas

## parfait-bluberi | Parfait Yoghurt Bluberi | 10 | 2 | mudah
tag: sarapan, camilan, manis, tanpa-kompor, vegetarian
desc: Lapisan yoghurt, oat, dan bluberi.
bahan:
- blueberry* | 100 g
- yogurt* | 200 g
- oats | 4 sdm
- honey | 1 sdm
langkah:
1. Cuci bluberi dan tiriskan.
2. Susun yoghurt, oat, dan bluberi berlapis di gelas.
3. Siram madu di bagian atas.
alat: gelas, sendok

## overnight-oats-ceri | Overnight Oats Ceri | 10 | 1 | mudah
tag: sarapan, manis, tanpa-kompor, vegetarian
desc: Oat rendam susu semalam dengan ceri.
bahan:
- cherry* | 10 buah
- oats* | 50 g
- milk | 150 ml
- honey? | 1 sdt
langkah:
1. Belah ceri dan buang bijinya.
2. Campur oat, susu, dan madu di wadah bertutup.
3. Beri ceri di atasnya, simpan di kulkas semalam.
alat: wadah bertutup, pisau, sendok

## susu-kurma | Susu Kurma | 5 | 2 | mudah
tag: minuman, sarapan, manis, tanpa-kompor, vegetarian
desc: Susu kental manis alami dari kurma yang diblender.
bahan:
- date* | 6 buah
- milk* | 300 ml
- ice? | 4 kotak
langkah:
1. Buang biji kurma.
2. Blender kurma bersama susu sampai halus.
3. Sajikan dingin atau hangat.
alat: blender, pisau, gelas

## wedang-asam-jawa | Wedang Asam Jawa | 15 | 2 | mudah
tag: minuman, segar, vegetarian
desc: Minuman asam jawa dan gula merah yang hangat.
bahan:
- tamarind* | 30 g
- palm_sugar | 60 g
- water | 500 ml
- ginger? | 2 cm
- salt | sejumput
langkah:
1. Rebus air bersama asam jawa, gula merah, jahe, dan garam.
2. Masak 10 menit sampai gula larut.
3. Saring dan sajikan hangat atau dingin.
alat: panci, saringan, gelas

## sup-sawi-putih-tahu | Sup Sawi Putih Tahu | 20 | 3 | mudah
tag: berkuah, hemat, sehat, vegetarian
desc: Sup bening sawi putih dan tahu.
bahan:
- napa_cabbage* | 1/2 bonggol
- tofu* | 2 potong
- garlic | 3 siung
- carrot? | 1 buah
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 800 ml
langkah:
1. Potong sawi putih, tahu, dan wortel.
2. Tumis bawang putih sampai harum, tuang air dan didihkan.
3. Masukkan wortel, lalu tahu dan sawi putih.
4. Bumbui garam dan merica, masak sampai sawi layu.
alat: panci, pisau, talenan, sendok sayur

## cah-pakcoy-bawang-putih | Cah Pakcoy Bawang Putih | 10 | 2 | mudah
tag: hemat, sehat, vegetarian
desc: Pakcoy yang ditumis cepat dengan bawang putih dan saus tiram.
bahan:
- bok_choy* | 3 bonggol
- garlic | 4 siung
- oyster_sauce | 1 sdm
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Belah pakcoy menjadi dua, cuci bersih.
2. Tumis bawang putih cincang sampai kecokelatan.
3. Masukkan pakcoy, saus tiram, garam, dan 2 sdm air.
4. Aduk cepat dengan api besar sampai layu.
alat: wajan, spatula, pisau

## tumis-pare-telur | Tumis Pare Telur | 20 | 2 | mudah
tag: hemat, pedas
desc: Pare iris tipis yang ditumis dengan telur orak-arik.
bahan:
- bitter_melon* | 1 buah
- egg* | 2 butir
- shallot | 3 siung
- garlic | 2 siung
- chili | 2 buah
- salt | 1 sdt
- cooking_oil | 2 sdm
langkah:
1. Iris tipis pare, remas dengan garam, diamkan 10 menit, lalu bilas untuk mengurangi pahit.
2. Tumis bawang merah, bawang putih, dan cabai sampai harum.
3. Masukkan telur, orak-arik sebentar.
4. Masukkan pare, aduk sampai layu, lalu angkat.
alat: wajan, spatula, pisau, talenan

## sayur-labu-siam-santan | Sayur Labu Siam Santan | 30 | 4 | mudah
tag: berkuah, hemat, vegetarian
desc: Labu siam dalam kuah santan yang gurih.
bahan:
- chayote* | 2 buah
- coconut_milk | 300 ml
- shallot | 4 siung
- garlic | 2 siung
- chili? | 2 buah
- bay_leaf | 2 lembar
- galangal | 2 cm
- salt | 1 sdt
langkah:
1. Kupas labu siam, potong korek api, remas dengan garam lalu bilas.
2. Tumis irisan bawang merah, bawang putih, cabai, daun salam, dan lengkuas.
3. Tuang santan dan 200 ml air, didihkan sambil diaduk.
4. Masukkan labu siam, masak sampai empuk, bumbui garam.
alat: panci, pisau, talenan, sendok sayur

## talas-goreng | Talas Goreng | 30 | 3 | mudah
tag: camilan, hemat, vegetarian
desc: Talas kukus yang digoreng sampai renyah.
bahan:
- taro* | 500 g
- garlic | 2 siung
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Kupas talas memakai sarung tangan, potong tebal, cuci bersih.
2. Kukus 15 menit sampai setengah empuk.
3. Lumuri bawang putih halus dan garam.
4. Goreng sampai kecokelatan dan renyah.
tip: Getah talas bisa membuat kulit gatal, jadi gunakan sarung tangan.
alat: kukusan, wajan, pisau, sarung tangan

## tumis-okra | Tumis Okra Bawang Putih | 15 | 2 | mudah
tag: hemat, sehat, vegetarian
desc: Okra yang ditumis singkat dengan bawang putih.
bahan:
- okra* | 200 g
- garlic | 3 siung
- chili? | 1 buah
- oyster_sauce? | 1 sdm
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Cuci okra, keringkan, lalu potong serong.
2. Tumis bawang putih dan cabai sampai harum.
3. Masukkan okra, aduk dengan api besar sekitar 4 menit.
4. Bumbui saus tiram dan garam.
alat: wajan, spatula, pisau

## sambal-goreng-petai-udang | Sambal Goreng Petai Udang | 25 | 3 | sedang
tag: pedas
desc: Udang dan petai dalam sambal merah.
bahan:
- petai* | 2 papan
- shrimp* | 250 g
- chili | 8 buah
- shallot | 6 siung
- garlic | 3 siung
- tomato | 1 buah
- sugar | 1 sdt
- salt | 1 sdt
- cooking_oil | 3 sdm
langkah:
1. Kupas petai dan belah dua. Kupas udang.
2. Haluskan cabai, bawang merah, bawang putih, dan tomat.
3. Tumis bumbu halus sampai matang dan berminyak.
4. Masukkan udang, masak sampai berubah warna.
5. Masukkan petai, bumbui gula dan garam, aduk 2 menit.
alat: wajan, spatula, blender, pisau

## semur-jengkol | Semur Jengkol | 90 | 4 | sedang
tag: berkuah
desc: Jengkol empuk dalam kuah kecap manis berempah.
bahan:
- jengkol* | 300 g
- sweet_soy_sauce | 4 sdm
- shallot | 6 siung
- garlic | 3 siung
- candlenut | 3 butir
- galangal | 2 cm
- bay_leaf | 2 lembar
- salt | 1 sdt
langkah:
1. Rendam jengkol semalam, lalu rebus 30 menit dan buang airnya. Ulangi sekali lagi.
2. Kupas kulit ari jengkol, geprek sampai pipih.
3. Haluskan bawang merah, bawang putih, dan kemiri, lalu tumis bersama lengkuas dan daun salam.
4. Masukkan jengkol, kecap, garam, dan 400 ml air.
5. Masak dengan api kecil sampai kuah mengental.
tip: Perebusan berulang mengurangi bau dan membuat jengkol empuk.
alat: panci, wajan, ulekan, pisau

## telur-dadar-kemangi | Telur Dadar Kemangi | 10 | 2 | mudah
tag: sarapan, hemat, vegetarian
desc: Telur dadar harum dengan daun kemangi.
bahan:
- egg* | 3 butir
- basil* | 1 genggam
- shallot | 2 siung
- chili? | 1 buah
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Petik daun kemangi, iris bawang merah dan cabai.
2. Kocok telur dengan garam, campur kemangi, bawang, dan cabai.
3. Goreng di wajan berminyak sampai kedua sisinya matang.
alat: wajan, spatula, mangkuk

## gulai-daun-singkong | Gulai Daun Singkong | 40 | 4 | sedang
tag: berkuah, pedas, vegetarian
desc: Daun singkong rebus dalam kuah santan kuning.
bahan:
- cassava_leaves* | 1 ikat
- coconut_milk | 500 ml
- shallot | 6 siung
- garlic | 3 siung
- chili | 4 buah
- turmeric | 2 cm
- ginger | 2 cm
- lemongrass | 1 batang
- salt | 1 sdt
langkah:
1. Petik daun singkong, rebus 15 menit sampai empuk, peras, lalu potong kasar.
2. Haluskan bawang merah, bawang putih, cabai, kunyit, dan jahe.
3. Tumis bumbu dengan serai sampai harum.
4. Tuang santan, didihkan sambil diaduk.
5. Masukkan daun singkong dan garam, masak 5 menit.
alat: panci, wajan, ulekan, pisau

## sup-kacang-polong-wortel | Sup Kacang Polong Wortel | 25 | 3 | mudah
tag: berkuah, sehat, anak, vegetarian
desc: Sup bening kacang polong dan wortel.
bahan:
- pea* | 150 g
- carrot* | 2 buah
- potato? | 1 buah
- garlic | 3 siung
- celery? | 1 batang
- salt | 1 sdt
- water | 800 ml
langkah:
1. Potong dadu wortel dan kentang.
2. Tumis bawang putih, tuang air, lalu didihkan.
3. Masukkan wortel dan kentang, masak 10 menit.
4. Masukkan kacang polong dan seledri, bumbui garam, masak 5 menit.
alat: panci, pisau, talenan

## wedang-rempah | Wedang Rempah | 20 | 2 | mudah
tag: minuman, vegetarian
desc: Minuman hangat jahe dengan kayu manis, cengkeh, dan serai.
bahan:
- ginger* | 5 cm
- cinnamon | 1 batang
- clove | 4 butir
- lemongrass | 1 batang
- star_anise? | 1 buah
- palm_sugar | 50 g
- water | 600 ml
langkah:
1. Bakar jahe sebentar, lalu geprek. Geprek serai.
2. Rebus air bersama semua rempah dan gula merah.
3. Kecilkan api, masak 15 menit.
4. Saring dan sajikan hangat.
alat: panci, saringan, gelas

## cumi-tumis-cabai-hijau | Cumi Tumis Cabai | 20 | 3 | sedang
tag: pedas
desc: Cumi yang ditumis cepat dengan cabai dan bawang.
bahan:
- squid* | 300 g
- chili | 6 buah
- shallot | 5 siung
- garlic | 3 siung
- tomato? | 1 buah
- sweet_soy_sauce? | 1 sdm
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Bersihkan cumi, buang tinta dan tulang rawannya, potong cincin.
2. Iris cabai, bawang merah, dan bawang putih.
3. Tumis bumbu sampai harum, masukkan cumi.
4. Masak dengan api besar sekitar 3 menit, bumbui garam dan kecap.
tip: Masak cumi sebentar saja agar tidak alot.
alat: wajan, spatula, pisau, talenan

## kerang-rebus-serai | Kerang Rebus Serai | 20 | 3 | mudah
tag: berkuah
desc: Kerang yang direbus dengan serai dan jahe, disajikan dengan sambal.
bahan:
- clam* | 500 g
- lemongrass | 2 batang
- ginger | 3 cm
- kaffir_lime_leaf | 3 lembar
- salt | 1 sdt
- water | 1 liter
langkah:
1. Rendam kerang dalam air garam 30 menit, lalu sikat cangkangnya.
2. Didihkan air bersama serai, jahe, dan daun jeruk.
3. Masukkan kerang, rebus sampai cangkangnya terbuka.
4. Buang kerang yang tidak terbuka.
alat: panci, sikat, saringan

## sambal-kacang | Sambal Kacang | 20 | 4 | mudah
tag: pedas, vegetarian
desc: Sambal kacang tanah untuk gado-gado, pecel, atau sate.
bahan:
- peanut* | 200 g
- chili | 4 buah
- garlic | 2 siung
- palm_sugar | 50 g
- kaffir_lime_leaf? | 2 lembar
- salt | 1 sdt
- water | 200 ml
langkah:
1. Sangrai atau goreng kacang tanah sampai matang, lalu kupas kulit arinya.
2. Haluskan kacang bersama cabai, bawang putih, gula merah, dan garam.
3. Masak dengan air dan daun jeruk sampai mengental.
alat: wajan, blender, spatula

## kacang-mete-madu | Kacang Mete Panggang Madu | 20 | 4 | mudah
tag: camilan, manis, vegetarian
desc: Kacang mete yang dipanggang dengan madu.
bahan:
- cashew* | 200 g
- honey | 2 sdm
- salt | sejumput
- cinnamon? | 1/4 sdt
langkah:
1. Sangrai kacang mete di teflon dengan api kecil sampai kekuningan.
2. Tuang madu, garam, dan kayu manis, aduk sampai rata.
3. Dinginkan di piring datar agar tidak lengket.
alat: teflon, spatula, piring

## susu-almond-kurma | Susu Almond Kurma | 10 | 2 | mudah
tag: minuman, sarapan, manis, tanpa-kompor, vegetarian
desc: Susu almond rumahan yang dimaniskan kurma.
bahan:
- almond* | 100 g
- date | 4 buah
- water | 500 ml
langkah:
1. Rendam almond dalam air minimal 8 jam, lalu tiriskan.
2. Blender almond, kurma tanpa biji, dan air sampai halus.
3. Saring dengan kain atau saringan halus.
alat: blender, saringan, kain saring

## susu-cokelat-hangat | Susu Cokelat Hangat | 10 | 2 | mudah
tag: minuman, manis, anak, vegetarian
desc: Susu hangat dengan cokelat batang yang dilelehkan.
bahan:
- chocolate* | 60 g
- milk* | 400 ml
- sugar? | 1 sdm
langkah:
1. Potong kecil cokelat.
2. Panaskan susu dengan api kecil, jangan sampai mendidih.
3. Masukkan cokelat dan gula, aduk sampai larut.
alat: panci, pisau, gelas

## singkong-goreng-bawang | Singkong Goreng Bawang | 40 | 4 | mudah
tag: camilan, hemat, vegetarian
desc: Singkong rebus berbumbu bawang yang digoreng renyah.
bahan:
- cassava* | 500 g
- garlic | 4 siung
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Kupas singkong, potong, cuci bersih.
2. Rebus dengan bawang putih halus dan garam sampai merekah.
3. Tiriskan, lalu goreng sampai kecokelatan.
tip: Singkong yang direbus sampai merekah menjadi renyah di luar dan lembut di dalam.
alat: panci, wajan, pisau

## tumis-tauge-tahu | Tumis Tauge Tahu | 15 | 2 | mudah
tag: hemat, vegetarian
desc: Tauge dan tahu yang ditumis cepat.
bahan:
- bean_sprout* | 200 g
- tofu* | 2 potong
- garlic | 3 siung
- shallot | 2 siung
- oyster_sauce? | 1 sdm
- salt | 1/4 sdt
- cooking_oil | 2 sdm
langkah:
1. Potong dadu tahu, goreng sebentar.
2. Tumis bawang merah dan bawang putih sampai harum.
3. Masukkan tahu dan tauge, bumbui saus tiram dan garam.
4. Aduk dengan api besar sekitar 1 menit agar tauge tetap renyah.
alat: wajan, spatula, pisau

## rujak-bengkuang-kedondong | Rujak Bengkuang Kedondong | 15 | 3 | mudah
tag: camilan, pedas, segar, tanpa-kompor, vegetarian
desc: Bengkuang dan kedondong dengan sambal gula merah.
bahan:
- jicama* | 1 buah
- ambarella? | 3 buah
- cucumber? | 1 buah
- palm_sugar | 60 g
- tamarind | 1 sdt
- chili | 2 buah
- salt | 1/4 sdt
langkah:
1. Kupas bengkuang dan kedondong, potong memanjang.
2. Ulek cabai, gula merah, asam jawa, dan garam sampai halus.
3. Sajikan buah dengan sambal.
alat: pisau, talenan, cobek

## jus-kedondong | Jus Kedondong | 10 | 2 | mudah
tag: minuman, segar, tanpa-kompor, vegetarian
desc: Jus kedondong asam segar.
bahan:
- ambarella* | 4 buah
- sugar | 2 sdm
- water | 300 ml
- ice | 4 kotak
langkah:
1. Kupas kedondong, iris dagingnya dan buang bijinya yang berserat.
2. Blender bersama air dan gula sampai halus.
3. Saring, lalu tambahkan es batu.
alat: blender, pisau, saringan, gelas

## sukun-goreng | Sukun Goreng | 30 | 4 | mudah
tag: camilan, hemat, vegetarian
desc: Irisan sukun yang direndam air garam lalu digoreng.
bahan:
- breadfruit* | 1/2 buah
- garlic | 2 siung
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Kupas sukun, buang bagian tengahnya, potong tebal.
2. Rendam dalam air garam dan bawang putih halus selama 10 menit.
3. Tiriskan dan goreng sampai kuning kecokelatan.
alat: wajan, pisau, talenan

## sayur-asem-melinjo | Sayur Asem Melinjo | 40 | 5 | mudah
tag: berkuah, segar, hemat, vegetarian
desc: Sayur asem dengan melinjo, labu siam, kacang panjang, dan jagung.
bahan:
- melinjo* | 1 genggam
- chayote | 1 buah
- long_bean | 1 ikat kecil
- corn | 1 buah
- peanut? | 50 g
- tamarind | 2 sdm
- palm_sugar | 30 g
- shallot | 4 siung
- garlic | 2 siung
- galangal | 2 cm
- bay_leaf | 2 lembar
- salt | 1 sdt
langkah:
1. Potong labu siam, kacang panjang, dan jagung.
2. Haluskan bawang merah dan bawang putih.
3. Rebus 1,5 liter air dengan bumbu halus, lengkuas, dan daun salam.
4. Masukkan jagung, melinjo, dan kacang tanah, masak 10 menit.
5. Masukkan labu siam dan kacang panjang, lalu asam jawa, gula merah, dan garam.
6. Masak sampai sayur empuk.
alat: panci, pisau, talenan, ulekan

## sambal-teri-kacang | Teri Kacang Balado | 25 | 4 | mudah
tag: pedas
desc: Ikan teri dan kacang tanah goreng dengan sambal merah.
bahan:
- anchovy* | 100 g
- peanut | 100 g
- chili | 8 buah
- shallot | 5 siung
- garlic | 2 siung
- sugar | 1 sdt
- salt | 1/4 sdt
- cooking_oil | secukupnya
langkah:
1. Cuci teri, tiriskan, lalu goreng sampai kering.
2. Goreng kacang tanah sampai matang.
3. Haluskan cabai, bawang merah, dan bawang putih, lalu tumis sampai matang.
4. Bumbui gula dan garam, masukkan teri dan kacang, aduk rata.
alat: wajan, spatula, blender

## telur-puyuh-balado | Telur Puyuh Balado | 30 | 3 | mudah
tag: pedas
desc: Telur puyuh rebus dalam sambal balado.
bahan:
- quail_egg* | 20 butir
- chili | 8 buah
- shallot | 5 siung
- garlic | 2 siung
- tomato | 1 buah
- sugar | 1 sdt
- salt | 1/2 sdt
- cooking_oil | 3 sdm
langkah:
1. Rebus telur puyuh 5 menit, rendam air dingin, lalu kupas.
2. Haluskan cabai, bawang merah, bawang putih, dan tomat.
3. Tumis bumbu sampai matang dan berminyak.
4. Masukkan telur, bumbui gula dan garam, aduk rata.
alat: panci, wajan, blender, spatula

## gulai-kambing | Gulai Kambing | 120 | 5 | sulit
tag: berkuah, pedas
desc: Daging kambing dalam kuah santan berempah.
bahan:
- goat_meat* | 500 g
- coconut_milk | 600 ml
- shallot | 8 siung
- garlic | 4 siung
- chili | 5 buah
- candlenut | 4 butir
- turmeric | 3 cm
- ginger | 3 cm
- lemongrass | 2 batang
- cinnamon | 1 batang
- clove | 3 butir
- kaffir_lime_leaf | 4 lembar
- salt | 2 sdt
langkah:
1. Rebus daging kambing 10 menit, buang airnya, lalu potong-potong.
2. Haluskan bawang merah, bawang putih, cabai, kemiri, kunyit, dan jahe.
3. Tumis bumbu halus bersama serai, kayu manis, cengkeh, dan daun jeruk sampai harum.
4. Masukkan daging dan 800 ml air, masak dengan api kecil sampai empuk.
5. Tuang santan dan garam, masak sambil diaduk sampai kuah sedikit mengental.
tip: Perebusan awal mengurangi bau prengus daging kambing.
alat: panci, wajan, blender, pisau

## tumis-kecipir | Tumis Kecipir | 15 | 2 | mudah
tag: hemat, vegetarian
desc: Kecipir iris yang ditumis dengan bawang dan cabai.
bahan:
- winged_bean* | 200 g
- shallot | 3 siung
- garlic | 2 siung
- chili? | 2 buah
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Iris serong kecipir.
2. Tumis bawang merah, bawang putih, dan cabai sampai harum.
3. Masukkan kecipir dan 2 sdm air, aduk sampai layu.
4. Bumbui garam, lalu angkat.
alat: wajan, spatula, pisau

## tumis-daun-pepaya-teri | Tumis Daun Pepaya Teri | 30 | 3 | sedang
tag: pedas, hemat
desc: Daun pepaya rebus yang ditumis dengan teri dan cabai.
bahan:
- papaya_leaves* | 1 ikat
- anchovy | 50 g
- shallot | 4 siung
- garlic | 2 siung
- chili | 4 buah
- salt | 1/2 sdt
- cooking_oil | 2 sdm
langkah:
1. Remas daun pepaya dengan garam, rebus 15 menit, lalu peras dan potong.
2. Goreng teri sampai kering.
3. Tumis bawang merah, bawang putih, dan cabai.
4. Masukkan daun pepaya dan teri, bumbui garam, aduk rata.
tip: Meremas dengan garam dan merebus daun pepaya mengurangi rasa pahitnya.
alat: panci, wajan, spatula, pisau

## sayur-jantung-pisang | Sayur Jantung Pisang Santan | 40 | 4 | sedang
tag: berkuah, vegetarian
desc: Jantung pisang dalam kuah santan kuning.
bahan:
- banana_blossom* | 1 buah
- coconut_milk | 400 ml
- shallot | 5 siung
- garlic | 2 siung
- turmeric | 2 cm
- galangal | 2 cm
- bay_leaf | 2 lembar
- salt | 1 sdt
langkah:
1. Buang kelopak luar jantung pisang, iris tipis bagian dalamnya, rebus 15 menit, lalu tiriskan.
2. Haluskan bawang merah, bawang putih, dan kunyit.
3. Tumis bumbu dengan lengkuas dan daun salam.
4. Tuang santan dan 200 ml air, didihkan, lalu masukkan jantung pisang dan garam.
alat: panci, wajan, pisau, ulekan

## sayur-rebung | Sayur Rebung Santan | 45 | 4 | sedang
tag: berkuah, vegetarian
desc: Rebung muda dalam kuah santan.
bahan:
- bamboo_shoot* | 300 g
- coconut_milk | 400 ml
- shallot | 5 siung
- garlic | 2 siung
- chili? | 3 buah
- galangal | 2 cm
- bay_leaf | 2 lembar
- salt | 1 sdt
langkah:
1. Iris tipis rebung, rebus 20 menit, buang airnya.
2. Haluskan bawang merah, bawang putih, dan cabai.
3. Tumis bumbu dengan lengkuas dan daun salam.
4. Tuang santan dan 200 ml air, masukkan rebung, masak sampai mendidih.
tip: Rebung harus direbus dan airnya dibuang sebelum dimasak agar tidak pahit.
alat: panci, wajan, pisau, ulekan

## tumis-jamur-kuping | Tumis Jamur Kuping Telur | 15 | 2 | mudah
tag: hemat, vegetarian
desc: Jamur kuping kenyal yang ditumis dengan telur.
bahan:
- wood_ear* | 50 g kering
- egg | 2 butir
- garlic | 3 siung
- spring_onion | 1 batang
- oyster_sauce? | 1 sdm
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Rendam jamur kuping dalam air hangat 15 menit sampai mengembang, lalu potong.
2. Tumis bawang putih, masukkan telur dan orak-arik.
3. Masukkan jamur, saus tiram, garam, dan daun bawang, aduk 2 menit.
alat: wajan, spatula, mangkuk

## jus-bit-apel | Jus Bit Apel | 10 | 2 | mudah
tag: minuman, sehat, tanpa-kompor, vegetarian
desc: Jus bit merah dengan apel.
bahan:
- beetroot* | 1 buah
- apple* | 1 buah
- lemon? | 1/2 buah
- water | 250 ml
langkah:
1. Kupas bit, potong kecil. Potong apel.
2. Blender bersama air dan perasan lemon.
3. Saring dan sajikan dingin.
alat: blender, pisau, saringan, gelas

## sup-kacang-merah | Sup Kacang Merah | 90 | 4 | sedang
tag: berkuah
desc: Sup kacang merah dengan daging sapi dan wortel.
bahan:
- kidney_bean* | 200 g
- beef | 250 g
- carrot | 1 buah
- potato? | 1 buah
- garlic | 3 siung
- shallot | 3 siung
- nutmeg? | 1/4 sdt
- pepper | 1/4 sdt
- salt | 1 sdt
langkah:
1. Rendam kacang merah semalam, lalu rebus 45 menit sampai empuk.
2. Rebus daging sapi dalam 1,5 liter air sampai empuk.
3. Tumis bawang merah dan bawang putih, masukkan ke kuah daging.
4. Masukkan kacang merah, wortel, dan kentang, bumbui pala, merica, dan garam.
5. Masak sampai sayur empuk.
alat: panci, wajan, pisau

## susu-kedelai | Susu Kedelai | 60 | 4 | sedang
tag: minuman, vegetarian
desc: Susu kedelai rumahan dengan daun pandan.
bahan:
- soybean* | 200 g
- pandan? | 2 lembar
- sugar | 4 sdm
- water | 1,5 liter
langkah:
1. Rendam kedelai semalam, lalu kupas kulit arinya.
2. Blender dengan sebagian air, lalu saring dengan kain.
3. Rebus sarinya dengan sisa air, pandan, dan gula sambil diaduk sampai mendidih.
4. Kecilkan api, masak 15 menit lagi agar matang sempurna.
alat: blender, panci, kain saring

## cah-selada-air | Cah Selada Air Bawang Putih | 10 | 2 | mudah
tag: hemat, sehat, vegetarian
desc: Selada air yang ditumis cepat dengan bawang putih.
bahan:
- watercress* | 2 ikat
- garlic | 4 siung
- oyster_sauce? | 1 sdm
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Petik selada air, cuci bersih.
2. Tumis bawang putih sampai harum.
3. Masukkan selada air dan saus tiram, aduk cepat sampai layu.
alat: wajan, spatula, pisau

## tumis-kale-bawang | Tumis Kale Bawang Putih | 10 | 2 | mudah
tag: sehat, vegetarian
desc: Daun kale yang ditumis dengan bawang putih dan sedikit cabai.
bahan:
- kale* | 1 ikat
- garlic | 3 siung
- chili? | 1 buah
- salt | 1/4 sdt
- cooking_oil | 1 sdm
langkah:
1. Buang tulang daun kale, sobek kecil-kecil.
2. Tumis bawang putih dan cabai.
3. Masukkan kale dan 2 sdm air, aduk sampai layu, bumbui garam.
alat: wajan, spatula, pisau

## soto-ayam | Soto Ayam | 60 | 4 | sedang
tag: berkuah
desc: Kuah kuning berbumbu kunyit dengan suwiran ayam, soun, dan tauge.
bahan:
- chicken* | 500 g
- vermicelli | 50 g soun
- bean_sprout | 100 g
- egg? | 2 butir rebus
- cabbage? | 100 g
- shallot | 6 siung
- garlic | 4 siung
- turmeric | 2 ruas
- ginger | 1 ruas
- candlenut | 3 butir
- lemongrass | 2 batang
- kaffir_lime_leaf | 3 lembar
- celery | 2 batang
- lime | 1 buah
- salt | 2 sdt
- cooking_oil | 2 sdm
- water | 1,5 liter
langkah:
1. Rebus ayam dalam air sampai matang, sekitar 30 menit, lalu angkat dan suwir dagingnya. Simpan kaldunya.
2. Haluskan bawang merah, bawang putih, kunyit, jahe, dan kemiri, lalu tumis bersama serai dan daun jeruk sampai harum.
3. Masukkan tumisan bumbu ke kaldu, beri garam, dan didihkan 10 menit.
4. Seduh soun dengan air panas sampai lunak, lalu seduh tauge sebentar.
5. Tata soun, tauge, kol iris, suwiran ayam, dan telur di mangkuk, lalu siram kuah panas.
6. Taburi seledri dan sajikan dengan perasan jeruk nipis.
tip: Ayam bertulang membuat kaldu lebih gurih.
alat: panci, wajan, spatula, ulekan, pisau, talenan, mangkuk
ganti: vermicelli = bihun atau mi

## martabak-manis-teflon | Martabak Manis Teflon | 90 | 4 | sedang
tag: camilan, manis, anak
desc: Martabak bersarang dengan isian cokelat, keju, dan kacang, dimatangkan di wajan teflon.
bahan:
- flour* | 250 g
- egg | 1 butir
- sugar | 3 sdm
- milk | 300 ml
- yeast | 1/2 sdt
- baking_powder | 1 sdt
- salt | 1/4 sdt
- butter | 3 sdm
- chocolate? | 50 g meses
- cheese? | 50 g parut
- peanut? | 50 g sangrai cincang
langkah:
1. Kocok telur dan gula, lalu masukkan terigu, susu, dan garam sedikit demi sedikit sampai adonan licin.
2. Tutup adonan dengan kain dan diamkan 1 jam.
3. Larutkan ragi dan baking powder dengan sedikit air, lalu aduk rata ke adonan.
4. Panaskan teflon dengan api kecil, tuang adonan setebal sekitar 1 cm, dan ratakan ke pinggir.
5. Biarkan sampai permukaan berlubang-lubang, taburi sedikit gula, lalu tutup sampai matang, sekitar 8 menit.
6. Angkat, olesi mentega, taburi meses, keju, dan kacang, lalu lipat dan potong.
tip: Api kecil dan teflon tebal membuat sarang terbentuk tanpa bagian bawah gosong.
alat: wajan teflon, mangkuk, pengocok, spatula, pisau

## martabak-telur | Martabak Telur | 40 | 4 | sedang
tag: camilan
desc: Kulit tipis berisi telur, daun bawang, dan daging cincang yang digoreng renyah.
bahan:
- spring_roll_wrapper* | 10 lembar
- egg* | 4 butir
- beef | 150 g cincang
- spring_onion | 3 batang
- onion | 1/2 buah
- garlic | 2 siung
- pepper | 1/2 sdt
- salt | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Tumis bawang putih dan bawang bombay, masukkan daging cincang, beri garam dan merica, lalu masak sampai matang.
2. Kocok telur, lalu campur dengan daging tumis dan irisan daun bawang.
3. Letakkan 2 sdm isian di tengah selembar kulit, lalu lipat menjadi amplop persegi.
4. Goreng dalam minyak panas dengan api sedang sampai kedua sisi kecokelatan.
5. Tiriskan, potong-potong, dan sajikan dengan acar atau cabai rawit.
tip: Jangan terlalu banyak isian agar kulit tidak sobek.
alat: wajan, spatula, mangkuk, pengocok, pisau, talenan
ganti: beef = daging ayam cincang

## klepon | Klepon | 45 | 4 | mudah
tag: camilan, manis, vegetarian
desc: Bola ketan hijau berisi gula merah cair yang dibalur kelapa parut.
bahan:
- glutinous_rice_flour* | 200 g
- palm_sugar* | 100 g
- coconut | 150 g parut kasar
- pandan | 5 lembar
- water | 150 ml
- salt | 1/4 sdt
langkah:
1. Blender daun pandan dengan air, lalu saring untuk mendapatkan air pandan.
2. Uleni tepung ketan dengan air pandan sedikit demi sedikit sampai bisa dibentuk dan tidak lengket.
3. Kukus kelapa parut yang diberi garam selama 10 menit.
4. Pipihkan sedikit adonan, isi dengan serutan gula merah, lalu bulatkan rapat.
5. Rebus dalam air mendidih dan angkat sekitar 3 menit setelah mengapung.
6. Gulingkan klepon di atas kelapa kukus dan sajikan.
tip: Tutup adonan rapat agar gula merah tidak bocor saat direbus.
alat: panci, kukusan, blender, saringan, mangkuk, sendok berlubang

## sate-ayam | Sate Ayam Bumbu Kacang | 60 | 4 | sedang
tag: anak
desc: Tusukan ayam bakar berbumbu kecap dengan saus kacang.
bahan:
- chicken* | 500 g fillet
- peanut | 150 g goreng
- sweet_soy_sauce | 5 sdm
- shallot | 5 siung
- garlic | 3 siung
- chili? | 3 buah
- candlenut | 2 butir
- palm_sugar | 1 sdm
- lime | 1 buah
- salt | 1 sdt
- cooking_oil | 2 sdm
- water | 200 ml
langkah:
1. Potong ayam dadu kecil, lumuri 2 sdm kecap manis dan sedikit garam, lalu diamkan 15 menit.
2. Tusuk 4 sampai 5 potong ayam pada setiap tusuk sate.
3. Haluskan kacang goreng, bawang merah, bawang putih, cabai, dan kemiri.
4. Tumis bumbu kacang, tambahkan air, gula merah, dan garam, lalu masak sampai mengental, sekitar 10 menit.
5. Bakar sate di teflon atau panggangan sambil dioles campuran kecap dan sedikit bumbu kacang sampai matang.
6. Sajikan dengan saus kacang, kecap, dan perasan jeruk nipis.
tip: Rendam tusuk sate dalam air 30 menit agar tidak mudah terbakar.
alat: wajan, teflon atau panggangan, tusuk sate, ulekan atau blender, pisau, talenan

## rawon | Rawon | 120 | 5 | sulit
tag: berkuah
desc: Sup daging berkuah hitam dari kluwek dengan aroma rempah khas Jawa Timur.
bahan:
- beef* | 500 g sandung lamur
- kluwek* | 5 buah
- shallot | 8 siung
- garlic | 5 siung
- candlenut | 3 butir
- turmeric | 1 ruas
- ginger | 1 ruas
- galangal | 2 ruas
- lemongrass | 2 batang
- kaffir_lime_leaf | 4 lembar
- coriander | 1 sdt
- salt | 2 sdt
- sugar | 1 sdt
- bean_sprout? | 100 g
- spring_onion | 2 batang
- cooking_oil | 3 sdm
- water | 2 liter
langkah:
1. Rebus daging sampai empuk, sekitar 60 menit, lalu potong dadu dan kembalikan ke kaldu.
2. Ambil isi kluwek dan rendam dengan sedikit air panas.
3. Haluskan bawang merah, bawang putih, kemiri, kunyit, jahe, ketumbar, dan isi kluwek.
4. Tumis bumbu halus bersama lengkuas geprek, serai, dan daun jeruk sampai harum dan matang.
5. Masukkan tumisan ke kaldu, beri garam dan gula, lalu masak dengan api kecil 30 menit.
6. Tambahkan daun bawang, lalu sajikan dengan tauge pendek dan sambal.
tip: Pilih kluwek yang isinya hitam legam dan tidak pahit; buang yang berjamur.
alat: panci, wajan, spatula, ulekan, pisau, talenan

## ayam-geprek | Ayam Geprek | 40 | 2 | sedang
tag: pedas
desc: Ayam goreng tepung renyah yang dipenyet dengan sambal bawang.
bahan:
- chicken* | 2 potong dada
- flour | 100 g
- egg | 1 butir
- chili* | 10 buah rawit
- garlic | 4 siung
- salt | 1 sdt
- pepper | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Lumuri ayam dengan garam, merica, dan 1 siung bawang putih halus, lalu diamkan 15 menit.
2. Celup ayam ke telur kocok, lalu gulingkan di terigu yang diberi garam sambil ditekan.
3. Goreng dalam minyak banyak dengan api sedang sampai kuning keemasan dan matang, sekitar 12 menit.
4. Ulek kasar cabai rawit, sisa bawang putih, dan garam, lalu siram dengan 2 sdm minyak panas.
5. Letakkan ayam di atas sambal, geprek dengan ulekan sampai sedikit pipih, lalu aduk dengan sambal.
tip: Sesuaikan jumlah cabai dengan selera pedas.
alat: wajan, ulekan, mangkuk, penjepit, pisau

## pempek-ikan | Pempek Ikan | 75 | 4 | sedang
desc: Olahan ikan dan tepung tapioka yang kenyal, disajikan dengan kuah cuko asam pedas manis.
bahan:
- fish* | 300 g daging ikan giling
- tapioca* | 250 g
- water | 150 ml dingin
- garlic | 6 siung
- palm_sugar | 150 g
- chili | 5 buah rawit
- tamarind | 1 sdm
- vinegar | 1 sdm
- egg? | 2 butir untuk kapal selam
- salt | 1,5 sdt
- sugar | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Campur ikan giling, air dingin, garam, gula, dan 1 siung bawang putih halus sampai rata.
2. Masukkan tapioka sedikit demi sedikit dan aduk ringan sampai bisa dibentuk.
3. Bentuk lonjong, atau pipihkan dan isi telur untuk kapal selam.
4. Rebus dalam air mendidih sampai mengapung, sekitar 10 menit, lalu tiriskan.
5. Untuk cuko, rebus gula merah, asam jawa, serta sisa bawang putih dan cabai yang dihaluskan dengan 400 ml air, lalu tambahkan cuka.
6. Goreng pempek sebentar sampai kulitnya kering, potong, dan sajikan dengan cuko.
tip: Adonan yang diaduk terlalu lama menjadi keras; cukup sampai rata.
alat: panci, wajan, mangkuk, ulekan, saringan, pisau

## cilok | Cilok Bumbu Kacang | 45 | 4 | mudah
tag: camilan, anak, hemat
desc: Bola tapioka kenyal yang direbus dan disajikan dengan saus kacang.
bahan:
- tapioca* | 200 g
- flour | 50 g
- garlic | 3 siung
- spring_onion | 2 batang
- water | 200 ml panas
- peanut | 100 g goreng
- chili? | 3 buah
- palm_sugar | 1 sdm
- sweet_soy_sauce? | 1 sdm
- salt | 1 sdt
langkah:
1. Campur tapioka, terigu, bawang putih halus, irisan daun bawang, dan garam.
2. Tuang air panas sedikit demi sedikit sambil diaduk, lalu uleni sampai bisa dibulatkan.
3. Bentuk bola kecil dan rebus dalam air mendidih sampai mengapung, sekitar 10 menit.
4. Haluskan kacang, cabai, gula merah, dan garam, lalu tambahkan air hangat sampai kental.
5. Tusuk cilok, siram saus kacang dan kecap, lalu sajikan.
tip: Air harus benar-benar panas agar adonan tapioka mudah dibentuk.
alat: panci, mangkuk, ulekan atau blender, sendok berlubang

## seblak | Seblak | 25 | 2 | mudah
tag: pedas, berkuah
desc: Kerupuk basah berkuah pedas dengan aroma kencur, telur, dan bakso.
bahan:
- cracker* | 100 g kerupuk mentah
- egg | 2 butir
- meatball? | 6 butir
- sausage? | 2 batang
- mustard_greens? | 1 ikat kecil
- kencur | 2 cm
- garlic | 3 siung
- shallot | 3 siung
- chili | 8 buah
- salt | 1 sdt
- sugar | 1/2 sdt
- cooking_oil | 2 sdm
- water | 400 ml
langkah:
1. Rendam kerupuk dalam air panas sampai lunak, sekitar 15 menit, lalu tiriskan.
2. Haluskan kencur, bawang putih, bawang merah, dan cabai.
3. Tumis bumbu sampai harum, masukkan telur, dan orak-arik sebentar.
4. Tambahkan air, bakso, dan sosis iris, lalu didihkan.
5. Masukkan kerupuk dan sawi, beri garam dan gula, lalu masak 3 menit sampai kuah sedikit mengental.
tip: Kencur adalah kunci aroma seblak dan tidak bisa diganti jahe.
alat: wajan, spatula, ulekan, mangkuk, pisau

## donat-kentang | Donat Kentang | 120 | 6 | sedang
tag: camilan, manis, anak
desc: Donat empuk dari adonan terigu dan kentang, ditaburi gula halus.
bahan:
- flour* | 500 g
- potato* | 200 g kukus dan haluskan
- yeast | 11 g
- sugar | 75 g
- egg | 2 kuning telur
- milk | 150 ml hangat
- butter | 50 g
- salt | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Campur terigu, ragi, dan gula, lalu masukkan kentang halus, kuning telur, dan susu hangat sedikit demi sedikit.
2. Uleni sampai setengah kalis, tambahkan mentega dan garam, lalu uleni lagi sampai kalis, sekitar 15 menit.
3. Tutup dan diamkan 60 menit sampai mengembang dua kali lipat.
4. Kempiskan, bagi menjadi bulatan 40 g, beri lubang di tengah, lalu diamkan lagi 20 menit.
5. Goreng dengan api kecil sampai kedua sisi kecokelatan, cukup sekali dibalik.
6. Tiriskan, lalu taburi gula halus atau oles cokelat leleh setelah dingin.
tip: Minyak yang terlalu panas membuat luar donat gosong sebelum bagian dalamnya matang.
alat: mangkuk besar, wajan, kukusan, sumpit atau spatula, kain penutup

## brownies-kukus | Brownies Kukus | 60 | 8 | sedang
tag: camilan, manis
desc: Kue cokelat lembap yang dimatangkan dengan dikukus, tanpa oven.
bahan:
- chocolate* | 150 g cokelat masak
- egg* | 4 butir
- butter | 100 g
- sugar | 150 g
- flour | 100 g
- baking_powder | 1/2 sdt
- salt | 1/4 sdt
langkah:
1. Lelehkan cokelat dan mentega di atas panci berisi air panas, lalu biarkan agak dingin.
2. Kocok telur dan gula sampai mengembang dan pucat, sekitar 8 menit.
3. Masukkan terigu, baking powder, dan garam yang sudah diayak sambil diaduk balik perlahan.
4. Tuang cokelat leleh dan aduk balik sampai rata.
5. Tuang ke loyang yang dioles mentega, lalu kukus 30 menit dengan api sedang; bungkus tutup kukusan dengan kain.
6. Dinginkan sebelum dipotong.
tip: Aduk balik dengan spatula agar udara dari kocokan telur tidak hilang.
alat: kukusan, loyang, mixer atau pengocok, mangkuk, spatula, kain

## bolu-pandan-kukus | Bolu Pandan Kukus | 50 | 8 | sedang
tag: camilan, manis
desc: Bolu hijau beraroma pandan yang ringan dan lembut.
bahan:
- flour* | 150 g
- egg* | 4 butir
- sugar | 150 g
- coconut_milk | 100 ml
- pandan | 10 lembar
- butter | 50 g leleh
- baking_powder | 1/2 sdt
- salt | 1/4 sdt
langkah:
1. Blender daun pandan dengan santan, lalu saring.
2. Kocok telur dan gula sampai kental berjejak, sekitar 10 menit.
3. Masukkan terigu, baking powder, dan garam yang diayak sambil diaduk balik.
4. Tambahkan santan pandan dan mentega leleh, lalu aduk balik sampai rata.
5. Tuang ke loyang dan kukus 25 menit dengan api sedang; bungkus tutup kukusan dengan kain.
tip: Lidi yang ditusukkan keluar bersih menandakan bolu sudah matang.
alat: kukusan, loyang, mixer atau pengocok, blender, saringan, spatula, kain

## kue-lapis | Kue Lapis | 90 | 8 | sedang
tag: camilan, manis, vegetarian
desc: Kue berlapis dari tepung beras dan tapioka bersantan yang dikukus selapis demi selapis.
bahan:
- rice_flour* | 150 g
- tapioca* | 100 g
- coconut_milk* | 700 ml
- sugar | 200 g
- pandan | 8 lembar
- salt | 1/2 sdt
langkah:
1. Rebus santan dengan gula, garam, dan 4 lembar daun pandan sampai gula larut, lalu dinginkan.
2. Campur tepung beras dan tapioka, lalu tuang santan sedikit demi sedikit sambil diaduk sampai licin.
3. Bagi adonan menjadi dua; satu bagian diberi air dari sisa daun pandan yang diblender agar hijau.
4. Kukus loyang kosong 5 menit, tuang satu sendok sayur adonan, lalu kukus 5 menit.
5. Tuang lapisan berikutnya dengan warna bergantian dan kukus 5 menit setiap lapis sampai adonan habis.
6. Kukus lapisan terakhir 15 menit, lalu dinginkan sepenuhnya sebelum dipotong.
tip: Potong dengan pisau yang diolesi minyak setelah kue benar-benar dingin.
alat: kukusan, loyang, mangkuk, sendok sayur, panci, blender, pisau

## onde-onde | Onde-onde | 60 | 6 | sedang
tag: camilan, manis, vegetarian
desc: Bola ketan bertabur wijen berisi kacang hijau manis, digoreng renyah.
bahan:
- glutinous_rice_flour* | 250 g
- mung_bean* | 150 g kupas
- sesame* | 75 g
- potato | 50 g kukus dan haluskan
- sugar | 100 g
- water | 150 ml
- pandan | 2 lembar
- salt | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Rendam kacang hijau 2 jam, kukus bersama pandan sampai lunak, lalu haluskan dengan 50 g gula dan sejumput garam, kemudian bulatkan kecil-kecil.
2. Campur tepung ketan, kentang halus, sisa gula, dan garam, lalu tuang air sedikit demi sedikit sampai bisa dibentuk.
3. Pipihkan adonan, isi bulatan kacang hijau, lalu bulatkan rapat.
4. Celupkan sebentar ke air, lalu gulingkan di wijen sambil ditekan.
5. Goreng dengan api kecil sampai mengembang dan kuning kecokelatan sambil sesekali ditekan dengan sutil.
tip: Masukkan ke minyak yang belum terlalu panas agar onde-onde tidak meletus.
alat: wajan, kukusan, mangkuk, sutil, ulekan

## lontong | Lontong | 240 | 6 | mudah
tag: hemat
desc: Nasi padat yang dibungkus daun pisang dan direbus lama, teman sayur bersantan atau sate.
bahan:
- rice* | 500 g beras
- salt | 1 sdt
- water | secukupnya
langkah:
1. Cuci beras, rendam 60 menit, lalu tiriskan dan campur dengan garam.
2. Gulung daun pisang menjadi tabung dan sematkan salah satu ujungnya dengan lidi.
3. Isi beras sekitar setengah sampai dua pertiga tabung, lalu tutup dan sematkan.
4. Rebus lontong dalam air yang menutupi seluruhnya selama 3 jam; tambahkan air panas bila menyusut.
5. Angkat dan tiriskan sampai dingin dan padat, baru dipotong.
tip: Beras yang terlalu penuh membuat lontong pecah, sedangkan yang terlalu sedikit membuatnya lembek.
alat: panci besar, daun pisang, lidi

## ketoprak | Ketoprak | 30 | 2 | mudah
tag: vegetarian
desc: Tahu goreng, bihun, tauge, dan lontong disiram saus kacang bawang putih.
bahan:
- tofu* | 4 potong
- peanut* | 150 g goreng
- vermicelli | 50 g bihun
- bean_sprout | 100 g
- rice? | 1 porsi lontong atau ketupat
- cucumber? | 1 buah
- garlic | 3 siung
- chili | 3 buah
- palm_sugar | 1 sdm
- sweet_soy_sauce | 3 sdm
- salt | 1/2 sdt
- water | 150 ml
- cooking_oil | secukupnya
langkah:
1. Goreng tahu sampai kecokelatan, lalu potong-potong.
2. Seduh bihun dan tauge dengan air panas sampai lunak, lalu tiriskan.
3. Ulek bawang putih, cabai, garam, dan gula merah, lalu masukkan kacang dan ulek kasar.
4. Tambahkan air sedikit demi sedikit sampai saus kental.
5. Tata lontong, tahu, bihun, tauge, dan timun, lalu siram saus kacang dan kecap.
tip: Bawang putih mentah memberi rasa khas ketoprak; sesuaikan jumlahnya.
alat: wajan, ulekan, mangkuk, pisau, talenan

## es-campur | Es Campur | 20 | 4 | mudah
tag: minuman, manis, segar, tanpa-kompor
desc: Minuman es dengan potongan buah, kelapa muda, dan susu kental manis.
bahan:
- coconut* | 1 buah kelapa muda
- avocado | 1 buah
- jackfruit | 100 g
- papaya? | 100 g
- milk | 100 ml susu kental manis
- sugar | 3 sdm
- ice* | 2 gelas es serut
langkah:
1. Potong dadu alpukat, nangka, dan pepaya.
2. Kerok daging kelapa muda dan simpan airnya.
3. Larutkan gula dalam air kelapa.
4. Tata buah dan kelapa di gelas saji, lalu tambahkan es serut.
5. Siram dengan air kelapa manis dan susu kental manis, lalu sajikan segera.
tip: Buah lain seperti melon atau nanas juga cocok.
alat: pisau, talenan, gelas saji, sendok

## nasi-liwet | Nasi Liwet | 45 | 4 | mudah
desc: Nasi gurih bersantan dengan serai, salam, dan teri yang dimasak dalam satu panci.
bahan:
- rice* | 400 g beras
- coconut_milk | 200 ml
- water | 400 ml
- anchovy | 50 g
- shallot | 5 siung
- garlic | 3 siung
- lemongrass | 2 batang
- bay_leaf | 3 lembar
- chili? | 5 buah rawit utuh
- salt | 1 sdt
- cooking_oil | 2 sdm
langkah:
1. Cuci beras sampai airnya jernih.
2. Tumis irisan bawang merah dan bawang putih sampai harum, lalu masukkan teri dan goreng sampai renyah.
3. Masukkan beras, santan, air, serai geprek, daun salam, cabai, dan garam ke panci.
4. Masak sampai air terserap, aduk sekali, lalu masukkan tumisan teri.
5. Lanjutkan memasak dengan api sangat kecil selama 15 menit sampai tanak.
tip: Rice cooker juga bisa dipakai: masukkan semua bahan dan masak seperti biasa.
alat: panci tebal atau rice cooker, wajan, spatula

## soto-betawi | Soto Betawi | 120 | 5 | sedang
tag: berkuah
desc: Soto daging berkuah santan dan susu yang gurih, khas Jakarta.
bahan:
- beef* | 500 g
- coconut_milk | 400 ml
- milk | 200 ml
- potato | 2 buah
- tomato | 2 buah
- shallot | 6 siung
- garlic | 4 siung
- candlenut | 3 butir
- ginger | 1 ruas
- galangal | 1 ruas
- lemongrass | 2 batang
- bay_leaf | 2 lembar
- nutmeg | 1/4 sdt
- coriander | 1 sdt
- salt | 2 sdt
- spring_onion | 2 batang
- lime | 1 buah
- cooking_oil | 3 sdm
- water | 1,5 liter
langkah:
1. Rebus daging sampai empuk, sekitar 60 menit, lalu potong dadu dan simpan kaldunya.
2. Haluskan bawang merah, bawang putih, kemiri, jahe, dan ketumbar, lalu tumis bersama lengkuas, serai, dan salam sampai harum.
3. Masukkan tumisan ke kaldu bersama daging dan pala, lalu didihkan.
4. Tuang santan dan susu, beri garam, lalu masak dengan api kecil 15 menit sambil diaduk agar santan tidak pecah.
5. Goreng kentang yang dipotong dadu.
6. Sajikan dengan kentang goreng, tomat, daun bawang, dan perasan jeruk nipis.
tip: Aduk terus saat santan dan susu dimasukkan agar kuah tetap halus.
alat: panci, wajan, spatula, ulekan, pisau, talenan

## mie-ayam | Mie Ayam | 50 | 4 | sedang
desc: Mi kenyal dengan topping ayam kecap jamur, sawi, dan kuah kaldu.
bahan:
- noodle* | 400 g mi telur basah
- chicken* | 300 g fillet paha
- mushroom | 100 g
- mustard_greens | 1 ikat
- garlic | 4 siung
- shallot | 4 siung
- ginger | 1 ruas
- sweet_soy_sauce | 4 sdm
- soy_sauce | 2 sdt
- oyster_sauce | 1 sdm
- pepper | 1/2 sdt
- salt | 1 sdt
- spring_onion | 2 batang
- cooking_oil | 4 sdm
- water | 1 liter
langkah:
1. Potong dadu ayam dan jamur.
2. Tumis bawang merah, bawang putih, dan jahe sampai harum, masukkan ayam dan jamur, lalu beri kecap manis, 1 sdt kecap asin, saus tiram, dan sedikit air, kemudian masak sampai meresap.
3. Rebus air dengan garam dan merica untuk kuah; tambahkan tulang ayam bila ada.
4. Rebus mi dan sawi sebentar, lalu tiriskan.
5. Aduk mi di mangkuk dengan 1 sdm minyak bekas menumis dan sisa kecap asin.
6. Beri topping ayam, sawi, dan daun bawang, lalu sajikan dengan kuah terpisah.
tip: Minyak bekas menumis bawang membuat mi lebih harum.
alat: wajan, panci, spatula, saringan, mangkuk, pisau

## cireng | Cireng | 30 | 4 | mudah
tag: camilan, hemat, vegetarian
desc: Gorengan tapioka yang renyah di luar dan kenyal di dalam.
bahan:
- tapioca* | 250 g
- flour | 2 sdm
- garlic | 3 siung
- spring_onion | 2 batang
- salt | 1 sdt
- pepper | 1/4 sdt
- water | 200 ml
- chili_sauce? | secukupnya
- cooking_oil | secukupnya
langkah:
1. Rebus air dengan bawang putih halus, garam, dan merica sampai mendidih.
2. Masukkan 3 sdm tapioka ke air mendidih dan aduk sampai menjadi biang yang kental dan bening.
3. Tuang biang ke sisa tapioka, terigu, dan daun bawang, lalu aduk dan uleni asal rata.
4. Bentuk pipih tipis dan taburi sedikit tapioka agar tidak lengket.
5. Goreng dengan api sedang sampai renyah, lalu sajikan dengan sambal.
tip: Jangan terlalu lama menguleni agar cireng tetap kenyal.
alat: panci, wajan, mangkuk, sendok, sutil

## batagor | Batagor | 60 | 4 | sedang
tag: camilan
desc: Bakso tahu goreng dari ikan dan tapioka, disiram saus kacang.
bahan:
- fish* | 250 g ikan giling
- tofu* | 8 potong
- tapioca | 100 g
- egg | 1 butir
- spring_onion | 2 batang
- garlic | 3 siung
- peanut | 150 g goreng
- chili? | 3 buah
- palm_sugar | 1 sdm
- sweet_soy_sauce | 2 sdm
- lime | 1 buah
- salt | 1 sdt
- pepper | 1/2 sdt
- water | 200 ml
- cooking_oil | secukupnya
langkah:
1. Campur ikan giling, telur, bawang putih halus, daun bawang, garam, dan merica, lalu masukkan tapioka sedikit demi sedikit.
2. Belah tahu, keruk sedikit isinya, lalu isi dengan adonan ikan.
3. Bentuk sisa adonan menjadi bulatan pipih.
4. Goreng tahu isi dan adonan dengan api sedang sampai kering dan kecokelatan.
5. Haluskan kacang, cabai, gula merah, dan garam, tambahkan air, lalu masak sebentar sampai kental.
6. Potong batagor, siram saus kacang dan kecap, lalu beri perasan jeruk nipis.
tip: Api sedang membuat batagor matang sampai ke dalam dan tetap renyah.
alat: wajan, mangkuk, ulekan atau blender, sendok, pisau

## siomay | Siomay | 60 | 4 | sedang
desc: Siomay ikan kukus dengan kentang, kol, telur, dan tahu, disiram saus kacang.
bahan:
- fish* | 250 g ikan giling
- tapioca | 100 g
- cabbage | 4 lembar
- potato | 2 buah
- egg | 3 butir
- tofu | 4 potong
- spring_onion | 2 batang
- garlic | 3 siung
- peanut | 150 g goreng
- palm_sugar | 1 sdm
- sweet_soy_sauce | 2 sdm
- lime | 1 buah
- salt | 1 sdt
- pepper | 1/2 sdt
- water | 200 ml
langkah:
1. Campur ikan giling, bawang putih halus, daun bawang, garam, merica, dan 1 butir telur, lalu masukkan tapioka sampai bisa dibentuk.
2. Isi lembaran kol yang sudah direbus dan tahu yang dibelah dengan adonan, lalu bulatkan sisanya.
3. Kukus siomay, kentang, dan 2 butir telur selama 30 menit.
4. Buat saus kacang dari kacang halus, gula merah, garam, dan air, lalu masak sampai kental.
5. Potong semua isian, siram saus kacang dan kecap, lalu beri perasan jeruk nipis.
tip: Alasi kukusan dengan daun kol agar siomay tidak lengket.
alat: kukusan, mangkuk, ulekan atau blender, panci, pisau

## risoles-ragout | Risoles Ragout | 75 | 6 | sedang
tag: camilan
desc: Dadar tipis berisi ragout ayam sayur, dibalut tepung panir dan digoreng.
bahan:
- flour* | 170 g
- breadcrumbs* | 100 g
- egg | 2 butir
- milk | 400 ml
- chicken | 150 g cincang
- carrot | 1 buah
- potato | 1 buah
- onion | 1/2 buah
- garlic | 2 siung
- butter | 2 sdm
- nutmeg? | sejumput
- salt | 1 sdt
- pepper | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Kocok 150 g terigu, 1 butir telur, 250 ml susu, dan sedikit garam sampai licin, lalu buat dadar tipis di teflon.
2. Tumis bawang bombay dan bawang putih dengan mentega, lalu masukkan ayam cincang serta wortel dan kentang yang dipotong dadu kecil.
3. Taburi sisa terigu, tuang sisa susu, beri garam, merica, dan pala, lalu masak sampai kental dan dinginkan.
4. Isi setiap kulit dengan ragout dan lipat seperti amplop.
5. Celup ke telur kocok, gulingkan di tepung panir, lalu goreng dengan api sedang sampai kuning keemasan.
tip: Ragout harus dingin dan kental agar mudah dibungkus dan tidak bocor.
alat: wajan teflon, wajan, panci kecil, mangkuk, pengocok, spatula

## lemper-ayam | Lemper Ayam | 90 | 6 | sedang
tag: camilan
desc: Ketan gurih berisi ayam suwir berbumbu yang dibungkus daun pisang.
bahan:
- glutinous_rice* | 400 g
- chicken* | 250 g
- coconut_milk | 300 ml
- shallot | 5 siung
- garlic | 3 siung
- coriander | 1 sdt
- candlenut | 2 butir
- palm_sugar | 1 sdm
- bay_leaf | 2 lembar
- lemongrass | 1 batang
- salt | 2 sdt
- cooking_oil | 2 sdm
langkah:
1. Rendam beras ketan 2 jam, kukus 20 menit, lalu aduk dengan santan panas bergaram sampai terserap dan kukus lagi 20 menit.
2. Rebus ayam, lalu suwir halus.
3. Tumis bawang merah, bawang putih, ketumbar, dan kemiri yang dihaluskan bersama salam dan serai, lalu masukkan ayam, gula merah, garam, dan sedikit santan, dan masak sampai kering.
4. Pipihkan ketan di atas daun pisang, beri isi ayam, lalu gulung padat.
5. Bungkus dengan daun pisang dan kukus lagi 10 menit agar harum.
tip: Basahi tangan dengan air saat membentuk ketan agar tidak lengket.
alat: kukusan, wajan, panci, daun pisang, ulekan

## serabi-kuah-kinca | Serabi Kuah Kinca | 60 | 4 | mudah
tag: sarapan, manis, vegetarian
desc: Kue tepung beras bersantan yang dimatangkan di wajan kecil, disiram kuah gula merah.
bahan:
- rice_flour* | 200 g
- palm_sugar* | 150 g
- coconut_milk | 450 ml
- flour | 2 sdm
- sugar | 1 sdm
- yeast | 1/2 sdt
- salt | 1/2 sdt
- pandan | 2 lembar
- water | 150 ml
langkah:
1. Campur tepung beras, terigu, gula, ragi, dan garam, lalu tuang 300 ml santan hangat sambil diaduk sampai licin. Diamkan 60 menit.
2. Untuk kinca, rebus gula merah, sisa santan, air, dan pandan sampai larut dan sedikit mengental.
3. Panaskan wajan kecil antilengket dengan api kecil, lalu tuang satu sendok sayur adonan.
4. Tutup dan masak sampai permukaan berlubang dan matang, sekitar 4 menit.
5. Sajikan serabi dengan kuah kinca.
tip: Api kecil membuat bagian bawah serabi kecokelatan tanpa gosong.
alat: wajan kecil antilengket, mangkuk, panci, sendok sayur

## dadar-gulung | Dadar Gulung | 45 | 6 | mudah
tag: camilan, manis, vegetarian
desc: Dadar pandan tipis berisi unti kelapa gula merah.
bahan:
- flour* | 150 g
- coconut* | 200 g parut
- egg | 1 butir
- coconut_milk | 350 ml
- pandan | 8 lembar
- palm_sugar | 125 g
- salt | 1/2 sdt
- water | 50 ml
- cooking_oil | 1 sdm
langkah:
1. Blender pandan dengan santan, lalu saring.
2. Kocok terigu, telur, santan pandan, dan sejumput garam sampai licin.
3. Untuk unti, masak kelapa parut, gula merah, sedikit garam, dan air sampai kering.
4. Dadar adonan tipis di teflon yang dioles minyak dengan api kecil.
5. Beri unti pada setiap dadar, lipat sisi kiri dan kanan, lalu gulung.
tip: Saring adonan agar dadar mulus tanpa gumpalan.
alat: wajan teflon, blender, saringan, mangkuk, pengocok, spatula

## kue-cubit | Kue Cubit | 30 | 4 | mudah
tag: camilan, manis, anak
desc: Kue kecil yang lembut dan setengah matang, dipanggang di cetakan.
bahan:
- flour* | 125 g
- egg | 2 butir
- sugar | 75 g
- milk | 150 ml
- butter | 30 g leleh
- baking_powder | 1 sdt
- chocolate? | 30 g meses
langkah:
1. Kocok telur dan gula sampai gula larut.
2. Masukkan terigu dan baking powder bergantian dengan susu sambil diaduk sampai licin.
3. Tambahkan mentega leleh dan aduk rata.
4. Panaskan cetakan kue cubit, olesi mentega, lalu isi adonan tiga perempat cetakan.
5. Taburi meses, tutup sebentar, lalu angkat saat permukaan masih sedikit basah, sekitar 3 menit.
tip: Angkat lebih cepat bila suka bagian tengah yang lumer.
alat: cetakan kue cubit, mangkuk, pengocok, sendok

## sop-buntut | Sop Buntut | 150 | 4 | sedang
tag: berkuah
desc: Sup bening buntut sapi dengan wortel, kentang, dan aroma pala serta cengkih.
bahan:
- beef* | 1 kg buntut sapi
- carrot | 2 buah
- potato | 2 buah
- tomato | 2 buah
- celery | 2 batang
- spring_onion | 2 batang
- garlic | 5 siung
- shallot? | 4 siung untuk bawang goreng
- nutmeg | 1/2 sdt
- clove | 3 butir
- cinnamon | 1 batang kecil
- pepper | 1 sdt
- lime | 1 buah
- salt | 2 sdt
- water | 2,5 liter
langkah:
1. Rebus buntut 10 menit, buang airnya, lalu bilas.
2. Rebus lagi dengan air baru bersama cengkih dan kayu manis dengan api kecil sampai empuk, sekitar 2 jam.
3. Tumis bawang putih halus sampai harum, lalu masukkan ke rebusan bersama pala, merica, dan garam.
4. Masukkan wortel dan kentang, lalu masak sampai empuk, sekitar 15 menit.
5. Tambahkan tomat, daun bawang, dan seledri sesaat sebelum diangkat.
6. Sajikan dengan bawang goreng dan perasan jeruk nipis.
tip: Membuang air rebusan pertama membuat kuah lebih bening.
alat: panci besar, wajan, pisau, talenan, sendok sayur

## kering-tempe | Kering Tempe | 40 | 4 | mudah
tag: manis, pedas, vegetarian, hemat
desc: Tempe goreng tipis berbalut bumbu gula merah pedas manis yang tahan lama.
bahan:
- tempeh* | 300 g
- peanut? | 50 g
- palm_sugar | 100 g
- shallot | 6 siung
- garlic | 3 siung
- chili | 5 buah
- galangal | 1 ruas
- bay_leaf | 2 lembar
- tamarind | 1 sdt
- salt | 1 sdt
- cooking_oil | secukupnya
langkah:
1. Iris tempe tipis seperti korek api, lalu goreng sampai kering dan renyah. Goreng juga kacang tanah.
2. Iris tipis bawang merah, bawang putih, dan cabai, lalu tumis bersama lengkuas dan daun salam.
3. Masukkan gula merah, air asam, dan garam, lalu masak sampai mengental dan berbuih.
4. Matikan api, masukkan tempe dan kacang, lalu aduk cepat sampai rata terbalut.
5. Dinginkan dan simpan dalam wadah tertutup.
tip: Matikan api sebelum tempe dimasukkan agar karamel tidak gosong dan tempe tetap renyah.
alat: wajan, spatula, pisau, talenan, wadah kedap udara

## cumi-goreng-tepung | Cumi Goreng Tepung | 25 | 2 | mudah
tag: camilan
desc: Cincin cumi bertepung renyah dengan saus sambal.
bahan:
- squid* | 300 g
- flour | 100 g
- tapioca | 2 sdm
- egg | 1 butir
- garlic | 2 siung
- lime | 1/2 buah
- salt | 1 sdt
- pepper | 1/2 sdt
- chili_sauce? | secukupnya
- cooking_oil | secukupnya
langkah:
1. Bersihkan cumi, potong cincin, lalu lumuri jeruk nipis, garam, merica, dan bawang putih halus, dan diamkan 10 menit.
2. Campur terigu, tapioka, dan sedikit garam.
3. Celup cumi ke telur kocok, lalu gulingkan di campuran tepung.
4. Goreng dalam minyak panas 2 sampai 3 menit sampai kuning keemasan.
5. Tiriskan dan sajikan dengan saus sambal.
tip: Cumi yang digoreng terlalu lama menjadi alot.
alat: wajan, mangkuk, penjepit, pisau, talenan

## pepes-ikan | Pepes Ikan | 60 | 4 | sedang
tag: sehat
desc: Ikan berbumbu kuning yang dibungkus daun pisang lalu dikukus, hampir tanpa minyak.
bahan:
- fish* | 500 g ikan kembung atau fillet
- shallot | 6 siung
- garlic | 3 siung
- turmeric | 2 ruas
- candlenut | 3 butir
- chili | 4 buah
- tomato | 1 buah
- basil | 1 ikat
- lemongrass | 2 batang
- bay_leaf | 4 lembar
- lime | 1 buah
- salt | 1,5 sdt
langkah:
1. Lumuri ikan dengan jeruk nipis dan garam, lalu diamkan 10 menit.
2. Haluskan bawang merah, bawang putih, kunyit, kemiri, dan cabai, lalu balurkan ke ikan.
3. Letakkan ikan di atas daun pisang bersama daun salam, serai, irisan tomat, dan kemangi.
4. Bungkus rapat dan sematkan dengan lidi.
5. Kukus 30 menit, lalu bakar sebentar di teflon bila ingin lebih harum.
tip: Karena dikukus, pepes cocok untuk menu rendah lemak.
alat: kukusan, daun pisang, lidi, ulekan, pisau, teflon

## botok-tempe-teri | Botok Tempe Teri | 60 | 4 | sedang
tag: sehat
desc: Kelapa parut berbumbu dengan tempe, teri, dan kemangi yang dibungkus daun pisang lalu dikukus.
bahan:
- coconut* | 200 g parut kasar
- tempeh | 150 g
- anchovy | 50 g
- shallot | 5 siung
- garlic | 2 siung
- chili | 3 buah
- galangal | 1 ruas
- basil | 1 ikat
- bay_leaf | 4 lembar
- palm_sugar | 1 sdt
- salt | 1 sdt
langkah:
1. Potong tempe dadu kecil, rendam teri sebentar, lalu tiriskan.
2. Haluskan bawang merah, bawang putih, cabai, lengkuas, gula merah, dan garam.
3. Campur kelapa parut dengan bumbu halus, tempe, teri, dan kemangi sampai rata.
4. Bungkus beberapa sendok adonan dengan daun pisang dan selembar daun salam, lalu sematkan dengan lidi.
5. Kukus 40 menit sampai matang.
tip: Kelapa setengah tua memberi rasa gurih tanpa terlalu berminyak.
alat: kukusan, daun pisang, lidi, ulekan, mangkuk

## nasi-bakar-ayam-kemangi | Nasi Bakar Ayam Kemangi | 60 | 4 | sedang
desc: Nasi gurih berisi ayam suwir kemangi yang dibungkus daun pisang lalu dibakar.
bahan:
- rice* | 600 g nasi hangat
- chicken* | 250 g
- basil | 1 ikat
- shallot | 5 siung
- garlic | 3 siung
- chili | 5 buah
- lemongrass | 1 batang
- bay_leaf | 2 lembar
- salt | 1,5 sdt
- cooking_oil | 2 sdm
langkah:
1. Aduk nasi hangat dengan sedikit garam, serai geprek, dan daun salam, lalu kukus 10 menit agar harum.
2. Rebus ayam, lalu suwir.
3. Tumis bawang merah, bawang putih, dan cabai yang dihaluskan, masukkan ayam dan garam, masak sampai kering, lalu masukkan kemangi.
4. Ratakan nasi di atas daun pisang, beri isi ayam, lalu bungkus dan sematkan dengan lidi.
5. Bakar di teflon atau panggangan sampai daun kecokelatan dan harum, sekitar 10 menit.
tip: Teflon tanpa minyak cukup untuk membakar bungkusan di rumah.
alat: kukusan, wajan, teflon, daun pisang, lidi, ulekan

## coto-makassar | Coto Makassar | 150 | 5 | sulit
tag: berkuah
desc: Sup daging berkuah kental dari kacang tanah sangrai dan air cucian beras, khas Makassar.
bahan:
- beef* | 500 g
- peanut* | 100 g sangrai dan haluskan
- rice | 2 genggam beras untuk air cucian
- shallot | 6 siung
- garlic | 5 siung
- galangal | 2 ruas
- lemongrass | 2 batang
- coriander | 1 sdm
- pepper | 1 sdt
- salt | 2 sdt
- spring_onion | 2 batang
- celery | 2 batang
- lime | 1 buah
- cooking_oil | 3 sdm
- water | 2,5 liter
langkah:
1. Cuci beras dan simpan air cucian kedua dan ketiga.
2. Rebus daging dalam air cucian beras bersama lengkuas dan serai sampai empuk, sekitar 90 menit, lalu potong kecil.
3. Sangrai ketumbar, lalu haluskan bersama bawang merah, bawang putih, dan merica.
4. Tumis bumbu sampai harum, lalu masukkan ke kaldu bersama kacang tanah halus dan garam.
5. Masak dengan api kecil 20 menit sampai kuah sedikit kental.
6. Sajikan dengan daun bawang, seledri, bawang goreng, jeruk nipis, dan ketupat.
tip: Air cucian beras membuat kuah coto lebih kental dan gurih.
alat: panci besar, wajan, ulekan, pisau, talenan

## papeda-ikan-kuah-kuning | Papeda dan Ikan Kuah Kuning | 60 | 4 | sedang
tag: berkuah
desc: Bubur sagu bening yang lengket, disajikan dengan ikan berkuah kunyit asam khas Maluku dan Papua.
bahan:
- sago* | 250 g
- fish* | 500 g tongkol atau kakap
- turmeric | 2 ruas
- shallot | 6 siung
- garlic | 3 siung
- chili | 4 buah
- lemongrass | 2 batang
- kaffir_lime_leaf | 3 lembar
- basil | 1 ikat
- tomato | 1 buah
- lime | 1 buah
- salt | 2 sdt
- cooking_oil | 2 sdm
- water | 1,5 liter
langkah:
1. Lumuri ikan dengan jeruk nipis dan garam.
2. Tumis bawang merah, bawang putih, kunyit, dan cabai yang dihaluskan bersama serai dan daun jeruk sampai harum.
3. Tuang 800 ml air dan didihkan, lalu masukkan ikan, garam, tomat, dan kemangi, dan masak 10 menit.
4. Untuk papeda, larutkan sagu dengan 200 ml air dingin, lalu siram dengan sisa air yang mendidih sambil diaduk cepat sampai bening dan lengket.
5. Sajikan papeda dengan ikan kuah kuning.
tip: Air harus benar-benar mendidih saat disiramkan agar sagu matang dan bening.
alat: panci, wajan, mangkuk tahan panas, sendok kayu, ulekan

## gudeg | Gudeg | 240 | 6 | sulit
tag: manis
desc: Nangka muda yang dimasak lama dengan santan dan gula merah sampai cokelat dan meresap.
bahan:
- jackfruit* | 1 kg nangka muda
- coconut_milk | 1 liter
- palm_sugar | 200 g
- egg? | 6 butir rebus
- shallot | 8 siung
- garlic | 5 siung
- candlenut | 4 butir
- coriander | 1 sdm
- galangal | 2 ruas
- bay_leaf | 5 lembar
- salt | 2 sdt
langkah:
1. Potong nangka muda, rebus 15 menit, lalu buang airnya.
2. Haluskan bawang merah, bawang putih, kemiri, dan ketumbar.
3. Alasi dasar panci dengan daun salam, lalu masukkan nangka, telur, bumbu halus, lengkuas, gula merah, dan garam.
4. Tuang santan sampai nangka terendam.
5. Masak dengan api kecil 3 jam sampai santan menyusut dan nangka berwarna cokelat; tambahkan santan bila terlalu cepat kering.
tip: Gudeg makin enak setelah dihangatkan ulang keesokan harinya.
alat: panci tebal, ulekan, pisau, talenan, sendok kayu

## ayam-betutu | Ayam Betutu | 120 | 4 | sulit
tag: pedas
desc: Ayam berbumbu rempah Bali yang dikukus lalu dipanggang, pedas dan harum.
bahan:
- chicken* | 1 ekor kecil
- shallot | 10 siung
- garlic | 6 siung
- chili | 10 buah
- turmeric | 3 ruas
- ginger | 2 ruas
- galangal | 2 ruas
- kencur | 2 ruas
- candlenut | 4 butir
- coriander | 1 sdt
- lemongrass | 2 batang
- kaffir_lime_leaf | 5 lembar
- lime | 1 buah
- salt | 2 sdt
- cooking_oil | 3 sdm
langkah:
1. Lumuri ayam dengan jeruk nipis dan garam, lalu diamkan 15 menit.
2. Haluskan bawang merah, bawang putih, cabai, kunyit, jahe, lengkuas, kencur, kemiri, dan ketumbar, lalu tumis bersama serai dan daun jeruk sampai matang.
3. Balurkan bumbu ke seluruh ayam, termasuk rongga perutnya.
4. Bungkus ayam dengan daun pisang dan kukus 60 menit.
5. Buka bungkusan, lalu panggang di teflon atau oven sampai kulit kecokelatan, sekitar 20 menit.
tip: Ayam yang dibumbui semalam rasanya lebih meresap.
alat: kukusan, wajan, teflon atau oven, daun pisang, ulekan

## tongseng-kambing | Tongseng Kambing | 90 | 4 | sedang
tag: pedas, berkuah
desc: Daging kambing berkuah santan encer dan kecap dengan kol dan tomat.
bahan:
- goat_meat* | 500 g
- cabbage | 200 g
- tomato | 2 buah
- coconut_milk | 300 ml
- sweet_soy_sauce | 5 sdm
- shallot | 6 siung
- garlic | 4 siung
- candlenut | 3 butir
- coriander | 1 sdt
- turmeric | 1 ruas
- ginger | 1 ruas
- galangal | 1 ruas
- lemongrass | 1 batang
- chili | 6 buah rawit
- salt | 1 sdt
- cooking_oil | 3 sdm
- water | 1 liter
langkah:
1. Rebus daging kambing dengan jahe dan serai sampai empuk, sekitar 45 menit, lalu potong kecil; simpan 500 ml kaldunya.
2. Haluskan bawang merah, bawang putih, kemiri, ketumbar, dan kunyit, lalu tumis bersama lengkuas sampai harum.
3. Masukkan daging, kaldu, santan, kecap manis, dan garam, lalu masak 15 menit.
4. Tambahkan kol, tomat, dan cabai rawit utuh, lalu masak sebentar sampai kol layu.
5. Sajikan hangat dengan nasi.
tip: Merebus dengan jahe dan serai mengurangi bau prengus daging kambing.
alat: panci, wajan, spatula, ulekan, pisau, talenan

## sate-kambing | Sate Kambing | 60 | 4 | sedang
desc: Sate daging kambing bumbu kecap dengan irisan bawang merah, tomat, dan cabai rawit.
bahan:
- goat_meat* | 500 g
- sweet_soy_sauce | 8 sdm
- shallot | 6 siung
- garlic | 3 siung
- tomato | 1 buah
- chili | 6 buah rawit
- lime | 1 buah
- pepper | 1/2 sdt
- salt | 1 sdt
- butter? | 2 sdm leleh
langkah:
1. Potong daging kambing dadu, lumuri bawang putih halus, merica, garam, dan 3 sdm kecap, lalu diamkan 30 menit.
2. Tusuk daging dengan tusuk sate.
3. Bakar sambil dioles campuran kecap dan mentega leleh sampai matang dan kecokelatan, sekitar 10 menit.
4. Iris bawang merah, tomat, dan cabai rawit, lalu campur dengan sisa kecap dan perasan jeruk nipis.
5. Sajikan sate dengan sambal kecap.
tip: Sate kambing yang dibakar terlalu lama menjadi alot.
alat: panggangan atau teflon, tusuk sate, pisau, talenan, mangkuk

## mie-aceh | Mie Aceh | 45 | 2 | sedang
tag: pedas
desc: Mi kuning tebal berbumbu kari pedas dengan udang, kol, dan tauge.
bahan:
- noodle* | 300 g mi kuning tebal
- shrimp* | 150 g
- cabbage | 100 g
- bean_sprout | 50 g
- tomato | 1 buah
- shallot | 5 siung
- garlic | 3 siung
- chili | 5 buah
- candlenut | 2 butir
- turmeric | 1 ruas
- ginger | 1 ruas
- coriander | 1/2 sdt
- star_anise | 1 butir
- sweet_soy_sauce | 2 sdm
- salt | 1 sdt
- lime | 1 buah
- cooking_oil | 3 sdm
- water | 200 ml
langkah:
1. Haluskan bawang merah, bawang putih, cabai, kemiri, kunyit, jahe, dan ketumbar.
2. Tumis bumbu bersama bunga lawang sampai harum dan matang.
3. Masukkan udang, tomat, dan kol, lalu aduk sampai udang berubah warna.
4. Tuang air, kecap, dan garam, lalu masukkan mi dan tauge.
5. Masak sampai kuah menyusut, kering atau sedikit berkuah sesuai selera.
6. Sajikan dengan irisan bawang merah, timun, dan jeruk nipis.
tip: Bumbu yang ditumis sampai benar-benar matang membuat mi tidak langu.
alat: wajan, spatula, ulekan, pisau, talenan

## kwetiau-goreng | Kwetiau Goreng | 25 | 2 | mudah
desc: Kwetiau basah yang digoreng dengan kecap, telur, ayam, dan sawi.
bahan:
- noodle* | 300 g kwetiau basah
- egg | 2 butir
- chicken | 100 g
- mustard_greens | 1 ikat kecil
- bean_sprout | 50 g
- garlic | 3 siung
- sweet_soy_sauce | 2 sdm
- soy_sauce | 1 sdm
- oyster_sauce | 1 sdm
- pepper | 1/2 sdt
- spring_onion | 1 batang
- cooking_oil | 3 sdm
langkah:
1. Tumis bawang putih sampai harum, masukkan ayam iris tipis, lalu masak sampai berubah warna.
2. Pinggirkan ayam, masukkan telur, lalu orak-arik.
3. Masukkan kwetiau, kecap manis, kecap asin, saus tiram, dan merica, lalu aduk dengan api besar.
4. Tambahkan sawi dan tauge, lalu aduk sebentar sampai layu.
5. Taburi daun bawang dan sajikan.
tip: Pisahkan helai kwetiau sebelum dimasak agar tidak menggumpal dan patah.
alat: wajan, spatula, pisau, talenan

## bihun-goreng | Bihun Goreng | 25 | 2 | mudah
tag: hemat
desc: Bihun goreng kecap dengan telur, kol, dan wortel.
bahan:
- vermicelli* | 200 g
- egg | 2 butir
- cabbage | 100 g
- carrot | 1 buah
- shallot | 3 siung
- garlic | 3 siung
- sweet_soy_sauce | 2 sdm
- soy_sauce | 1 sdm
- pepper | 1/2 sdt
- salt | 1/2 sdt
- spring_onion | 1 batang
- cooking_oil | 3 sdm
langkah:
1. Rendam bihun dengan air panas 5 menit sampai lunak, lalu tiriskan.
2. Tumis bawang merah dan bawang putih, masukkan telur, lalu orak-arik.
3. Masukkan wortel dan kol iris, lalu masak sampai layu.
4. Masukkan bihun, kecap manis, kecap asin, garam, dan merica, lalu aduk rata dengan api besar.
5. Taburi daun bawang dan sajikan.
tip: Bihun yang direndam terlalu lama menjadi lembek saat digoreng.
alat: wajan, spatula, mangkuk, pisau, talenan

## lumpia-semarang | Lumpia Semarang | 60 | 6 | sedang
tag: camilan
desc: Kulit lumpia berisi rebung, telur, dan udang yang digoreng renyah.
bahan:
- spring_roll_wrapper* | 15 lembar
- bamboo_shoot* | 300 g
- shrimp | 150 g
- egg | 2 butir
- garlic | 4 siung
- shallot | 3 siung
- sweet_soy_sauce | 1 sdm
- oyster_sauce | 1 sdm
- flour | 2 sdm
- pepper | 1/2 sdt
- salt | 1 sdt
- sugar | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Rebus rebung yang diiris korek api, buang airnya, lalu ulangi sekali agar baunya hilang.
2. Tumis bawang merah dan bawang putih, masukkan udang cincang dan telur, lalu orak-arik.
3. Masukkan rebung, kecap, saus tiram, garam, gula, dan merica, masak sampai kering, lalu dinginkan.
4. Isi kulit lumpia dengan 2 sdm isian, lipat sisi kiri dan kanan, gulung rapat, lalu rekatkan dengan terigu yang dilarutkan sedikit air.
5. Goreng dengan api sedang sampai kuning keemasan.
tip: Isian harus kering dan dingin agar kulit tidak basah dan sobek.
alat: wajan, panci, spatula, pisau, talenan

## pastel-sayur | Pastel Isi Sayur | 90 | 6 | sedang
tag: camilan
desc: Kue pastri goreng berisi kentang, wortel, bihun, dan telur rebus.
bahan:
- flour* | 300 g
- butter | 50 g
- egg | 3 butir
- water | 100 ml
- potato | 2 buah
- carrot | 1 buah
- vermicelli | 30 g
- garlic | 3 siung
- shallot | 3 siung
- spring_onion | 1 batang
- pepper | 1/2 sdt
- salt | 1,5 sdt
- cooking_oil | secukupnya
langkah:
1. Rebus 2 butir telur, lalu potong-potong.
2. Campur terigu, mentega, 1 butir telur, dan garam, tambahkan air sedikit demi sedikit, lalu uleni sampai kalis dan diamkan 20 menit.
3. Tumis bawang merah dan bawang putih, masukkan kentang dan wortel dadu kecil, bihun yang sudah direndam, garam, dan merica, lalu masak sampai matang dan kering.
4. Gilas adonan tipis dan potong bundar sekitar 10 cm.
5. Isi dengan sayuran dan sepotong telur, lipat menjadi setengah lingkaran, lalu pilin pinggirnya.
6. Goreng dengan api sedang sampai kuning kecokelatan.
tip: Adonan yang diistirahatkan lebih mudah digilas dan tidak menyusut.
alat: wajan, gilingan adonan, mangkuk, spatula, pisau

## kroket-kentang | Kroket Kentang | 60 | 6 | sedang
tag: camilan, anak
desc: Kentang tumbuk berisi ragout daging yang dibalut tepung panir dan digoreng.
bahan:
- potato* | 500 g
- breadcrumbs* | 100 g
- beef | 150 g cincang
- carrot | 1 buah
- onion | 1/2 buah
- garlic | 2 siung
- milk | 100 ml
- flour | 2 sdm
- egg | 2 butir
- butter | 1 sdm
- nutmeg | sejumput
- salt | 1,5 sdt
- pepper | 1/2 sdt
- cooking_oil | secukupnya
langkah:
1. Kukus kentang sampai empuk, lalu haluskan dengan mentega, 1 kuning telur, garam, merica, dan pala.
2. Tumis bawang bombay dan bawang putih, masukkan daging dan wortel dadu kecil, taburi terigu, tuang susu, masak sampai kental, lalu dinginkan.
3. Pipihkan adonan kentang, isi dengan ragout, lalu bentuk lonjong.
4. Celup ke sisa telur yang dikocok, lalu gulingkan di tepung panir.
5. Goreng dengan api sedang sampai kuning keemasan.
tip: Simpan kroket di kulkas 30 menit sebelum digoreng agar tidak pecah.
alat: kukusan, wajan, mangkuk, spatula, garpu

## smoothie-buah-naga-pisang | Smoothie Buah Naga Pisang | 5 | 2 | mudah
tag: minuman, sarapan, manis, segar, sehat, tanpa-kompor, vegetarian
desc: Minuman kental berwarna merah muda dari buah naga dan pisang yang diblender bersama susu atau yoghurt.
bahan:
- dragon_fruit* | 1 buah
- banana* | 1 buah matang
- milk | 200 ml
- yogurt? | 3 sdm
- honey? | 1 sdm
- ice? | 4 kotak
langkah:
1. Belah buah naga, keruk daging buahnya, lalu potong-potong bersama pisang.
2. Masukkan buah naga, pisang, susu, dan yoghurt ke blender.
3. Blender sampai halus, lalu cicipi dan tambahkan madu bila ingin lebih manis.
4. Tambahkan es batu, blender sebentar, dan sajikan segera.
tip: Pisang yang matang dan dibekukan membuat smoothie lebih kental tanpa banyak es.
alat: blender, pisau, talenan, gelas
ganti: milk = susu kedelai atau air kelapa; yogurt = susu tambahan
