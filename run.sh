set -e

cd /Users/michaelkreil/Projekte/versatiles/tilemaker

make

make install

cd /Users/michaelkreil/Projekte/versatiles/shortbread-tilemaker

./bin/3_generate_mbtiles.sh -b 11.2,51.3,14.8,53.6 brandenburg

versatiles serve -s ../versatiles-frontend/release/frontend-rust.br.tar data/result/brandenburg.mbtiles
