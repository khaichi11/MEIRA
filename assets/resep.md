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
    ganti: kunci = saran pengganti; ...

## smoothie-pisang-susu | Smoothie Pisang Susu | 5 | 1 | mudah
tag: sarapan, minuman, manis, anak, tanpa-kompor, vegetarian
desc: Minuman kental pengganjal pagi yang cuma butuh blender.
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
ganti: cantaloupe = pepaya; watermelon = melon hijau

## rujak-buah | Rujak Buah Sambal Gula Merah | 15 | 3 | mudah
tag: camilan, segar, pedas, tanpa-kompor, vegetarian
desc: Buah renyah dengan sambal gula merah pedas manis.
bahan:
- pineapple* | 1/4 buah
- mango* | 1 buah mengkal
- cucumber* | 1 buah
- apple? | 1 buah
- palm_sugar* | 75 g
- chili* | 3 buah cabai rawit
- peanut? | 2 sdm, sangrai
- salt | sejumput
langkah:
1. Potong semua buah memanjang.
2. Ulek cabai, garam, dan kacang tanah.
3. Tambahkan gula merah dan sedikit air, ulek sampai kental.
4. Sajikan buah dengan sambal di samping.
tip: Mangga yang masih agak muda memberi rasa asam yang pas untuk rujak.
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
ganti: lemon = jeruk nipis

## pisang-goreng | Pisang Goreng Tepung | 20 | 3 | mudah
tag: camilan, manis, anak, vegetarian, hemat
desc: Pisang berbalut adonan renyah, camilan sore klasik.
bahan:
- banana* | 4 buah, belah dua
- flour* | 100 g
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
ganti: banana = nangka atau ubi

## pisang-bakar-cokelat-keju | Pisang Bakar Cokelat Keju | 15 | 2 | mudah
tag: camilan, manis, anak, vegetarian
desc: Pisang dipanggang di teflon dengan lelehan cokelat dan keju.
bahan:
- banana* | 3 buah
- chocolate* | 2 sdm meses atau cokelat batang
- cheese* | 30 g, parut
- butter? | 1 sdm
langkah:
1. Belah pisang memanjang tanpa terputus.
2. Panaskan mentega di teflon, panggang pisang sampai kedua sisi kecokelatan.
3. Angkat, taburi cokelat dan keju parut selagi panas.
tip: Tekan pisang dengan spatula saat dipanggang agar lebih pipih dan matang merata.
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

## kolak-pisang-labu | Kolak Pisang Labu | 30 | 4 | sedang
tag: manis, berkuah, vegetarian
desc: Hidangan manis bersantan, hangat untuk berbuka atau sore hari.
bahan:
- banana* | 4 buah pisang kepok
- pumpkin* | 300 g
- coconut_milk* | 400 ml
- palm_sugar* | 100 g
- salt | sejumput
- water | 300 ml
langkah:
1. Potong labu dadu dan pisang serong.
2. Rebus air dengan gula merah sampai larut, saring.
3. Masukkan labu, masak sampai setengah empuk.
4. Tambahkan pisang, santan, dan garam; aduk terus sampai mendidih.
tip: Aduk santan terus agar tidak pecah.
ganti: pumpkin = ubi; coconut_milk = susu cair untuk versi lebih ringan

## overnight-oats-pisang | Overnight Oats Pisang Stroberi | 5 | 1 | mudah
tag: sarapan, sehat, tanpa-kompor, vegetarian
desc: Siapkan malam hari, besok pagi tinggal makan.
bahan:
- oats* | 5 sdm
- milk* | 150 ml
- banana* | 1 buah
- strawberry? | 4 buah
- honey? | 1 sdm
- yogurt? | 2 sdm
langkah:
1. Campur oat, susu, yoghurt, dan madu dalam wadah bertutup.
2. Tambahkan irisan pisang dan stroberi di atasnya.
3. Simpan di kulkas minimal 4 jam atau semalaman.
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

## telur-ceplok-kecap | Telur Ceplok Kecap | 10 | 2 | mudah
tag: hemat, anak, vegetarian
desc: Telur mata sapi bersiram kecap manis gurih.
bahan:
- egg* | 3 butir
- sweet_soy_sauce* | 2 sdm
- shallot | 3 siung, iris
- chili? | 2 buah, iris
- cooking_oil | 2 sdm
langkah:
1. Goreng telur ceplok satu per satu, sisihkan.
2. Tumis bawang merah dan cabai sampai harum.
3. Tambahkan kecap dan sedikit air, masak sebentar.
4. Masukkan telur, siram dengan kuah kecap sampai rata.

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

## jamur-crispy | Jamur Crispy | 20 | 3 | mudah
tag: camilan, vegetarian
desc: Jamur tiram goreng tepung yang renyah.
bahan:
- mushroom* | 250 g jamur tiram
- flour* | 100 g
- garlic | 2 siung, haluskan
- salt | 1 sdt
- pepper | 1/2 sdt
- cooking_oil | untuk menggoreng
langkah:
1. Suwir jamur, cuci dan peras sampai agak kering.
2. Lumuri jamur dengan bawang putih, garam, dan merica.
3. Gulingkan ke tepung sambil diremas agar tepung menempel.
4. Goreng di minyak panas sampai kering dan renyah.

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
ganti: winter_melon = labu siam

## gado-gado | Gado-gado Rumahan | 40 | 3 | sedang
tag: sehat, vegetarian
desc: Sayur rebus dengan saus kacang gurih manis.
bahan:
- cabbage* | 1/4 buah
- potato* | 2 buah
- egg* | 2 butir
- peanut* | 150 g kacang goreng atau 4 sdm selai kacang
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
ganti: shrimp = ayam atau tahu

## kepiting-saus-tiram | Kepiting Saus Tiram | 30 | 2 | sulit
tag: berkuah
desc: Kepiting dimasak dalam saus tiram jahe.
bahan:
- crab* | 2 ekor
- oyster_sauce* | 2 sdm
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

## tempe-orek | Tempe Orek Kecap | 20 | 3 | mudah
tag: hemat, vegetarian
desc: Tempe goreng kering berbalut kecap manis pedas.
bahan:
- tempeh* | 1 papan
- sweet_soy_sauce* | 3 sdm
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

## ayam-kecap | Ayam Kecap | 35 | 3 | sedang
tag: anak
desc: Ayam manis gurih dengan kuah kecap kental.
bahan:
- chicken* | 400 g
- sweet_soy_sauce* | 4 sdm
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
