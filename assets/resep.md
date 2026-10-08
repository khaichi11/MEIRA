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
