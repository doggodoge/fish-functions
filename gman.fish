# Defined interactively
function gman --description 'graphical man'
man -t $argv | gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -sOutputFile=/tmp/man.pdf - && open /tmp/man.pdf
end
