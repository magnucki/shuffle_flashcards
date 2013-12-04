#! /bin/bash
###########################################################
### Shellscript zum umsortieren von PDF Karteikarten im ### 
### Format Frage - Antwort - Frage Antwort [...]        ###
### Aktuell benötigte Programme:                        ###
### 'evince' zum Anzeigen der PDF                       ###
### 'pdftk' zum Auslesen und Bearbeiten der PDF         ###
### (c) Rico Magnucki rmagnuck@techfak.uni-bielefeld.de ###
### Version: 1.0                                        ###
###########################################################  

#Anzahl der PDF Seiten auslesen
function count()
{
n=$(pdftk $1 dump_data output | grep NumberOfPages | cut -c16-)
}

# Seiten mit Fragen rausfiltern
function get_questions()
{
for ((i=1; i<=$((($n)/2)); i++)); 
  do
    tmp1=$(((($i)*2)-1))
    array[$(($i-1))]=$tmp1
done
}

# Fragen neu sortieren
function shuffle()
{
for ((i=0; i<$((($n)/2)); i++)); 
  do
    new_position=$(($RANDOM % $(($n/2))))
    tmp=${array[$new_position]}
    array[$new_position]=${array[$i]}
    array[$i]=$tmp
done
}
# Jeder Frage die entsprechende Antwort zuordnen
function unite()
{
j=0
for ((i=0; i<$1; i++));
  do
    if [[($(($i % 2)) -ne 0)]]
      then
        erg[$i]=$[${array[$(($j))]}+1]
        j=$(($j+1))
      else
        erg[$i]=${array[$j]}
    fi
done
}




# PDF mit neuer Reihenfolge erstellen

function output()
{
pdftk $1 cat ${erg[*]} output $2
}



#################
# Hauptprogramm #
#################


function main()
{
    count $1
    get_questions $n
    shuffle $n
    unite $n
    output $1 $2
}

function help()
{
echo "PDF-Karteikarten-Shuffle"
echo "Nutzung:"
echo ""
echo "Ohne Parameter und ohne Ausgabedatei"
echo "./shuffle.sh Eingangspdf - Erzeugt eine paarweise gemischte Version"
echo ""
echo "Ohne Parameter mit Ausgangsdatei"
echo "./shuffle.sh [Eingangsdatei] [Ausgangsdatei] - Gemischte Version wird als [Ausgangsdatei] erzeugt." 
echo ""
echo "Mit Parameter und ohne Ausgabedatei"
echo "./shuffle.sh -s [Eingangsdatei] - Nach dem Erstellen wird die gemischte Version direkt mit Hilfe des Programms 'evince' angezeigt."
echo ""
echo "./shuffle.sh -l [Limit] [Eingangsdatei] - Erstellt eine PDF-Datei mit [Limit] Fragen."
echo ""
echo "Mit Parametern und mit Ausgangsdatei"
echo "./shuffle.sh -sl [Limit] [Ausgangsdatei] - Erstellt eine limitierte PDF mit dem Namen [Ausgangsdatei] und zeigt sie mit dem Programm 'evince' an"
echo
echo
}


case "$#" in
  1) case "$1" in
  --help) help;;
      -h) help;;
       *) main $1 "gemischt_"$1 
          echo "Gemischte Version steht unter "gemischt_$1" zur Verfügung";;
     esac;;
  2) case "$1" in
      -s) count $2
          get_questions $n
          shuffle $n
          unite $n
          output $2 "gemischt_"$2
          evince -s "gemischt_"$2;;
       *) main $1 $2;;
     esac;;    
  3) case "$1" in
      -s) count $2
          get_questions $n
          shuffle $n
          unite $n
          output $2 $3
          evince -s $3;;
      -l) count $3
          get_questions $n 
          shuffle $n
          unite $(($2 * 2))
          output $3 "gemischt_"$3;;
     -ls) count $3
          get_questions $n 
          shuffle $n
          unite $(($2 * 2))
          output $3 "gemischt_"$3
          evince -s "gemischt_"$3;;
     -sl) count $3
          get_questions $n 
          shuffle $n
          unite $(($2 * 2))
          output $3 "gemischt_"$3
          evince -s "gemischt_"$3;;
     esac;;
  4) case "$1" in
      -l) count $3
          get_questions $n 
          shuffle $n
          unite $(($2 * 2))
          output $3 $4;;
     -sl) count $1
          get_questions $n
          shuffle $n
          unite $(($2 * 2))
          output $3 $4
          evince -s $4;;
      *) echo "Unbekannte Option";;
    esac;;
   
  *) echo "Unbekannte Optionen";;
esac

#Auskommentieren wenn sofortige Anzeige im Präsentationsmodus gewünscht ist
#
#evince -s $1_gemischt.pdf
#
