#!/bin/bash

echo "Whoa, buddy. You really gonna try and just run this?" >&2
exit 1

TEdenovo.py -P ixodes -C TEdenovo.cfg -S 1
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 2 -s Blaster
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 2 --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 3 -s Blaster -c Grouper
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 3 -s Blaster -c Recon
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 3 -s Blaster -c Piler
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 3 --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 4 -s Blaster -c Grouper -m Map
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 4 -s Blaster -c Recon -m Map
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 4 -s Blaster -c Piler -m Map
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 4  -m Map --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 5 -s Blaster -c GrpRecPil -m Map
#TEdenovo.py -P ixodes -C TEdenovo.cfg -S 5 -s Blaster -m Map --struct ## No '-s Blaster' in this one
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 5 -m map --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 5 -s Blaster -c GrpRecPil -m Map --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 6 -s Blaster -c GrpRecPil -m Map
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 6 -m Map --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 6 -s Blaster -c GrpRecPil -m Map --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 7 -s Blaster -c GrpRecPil -m Map --struct
TEdenovo.py -P ixodes -C TEdenovo.cfg -S 8 -s Blaster -c GrpRecPil -m Map -f MCL --struct


FilterSeqClusters.py -i test_dc1_Blaster_Piler.map -m 3 -M 20 -L 20000 -d -v 3 > test_dc1_PilerFiltering.log
