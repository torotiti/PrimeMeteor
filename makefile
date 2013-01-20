# for WINDOWS
ifeq ($(OS), Windows_NT)
USER = $(USERNAME)
HTMLOPEN = start Safari.exe
else
# for Mac
HTMLOPEN = open -a Safari
endif

all: run

run:
	$(HTMLOPEN) index.html

