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
