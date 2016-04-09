# gen html documant from sgml

CV		= wiliki2html.scm
cvflags		=

infiles		= index.wiliki memo.wiliki start.wiliki wiliki2html.wiliki \
                  markdown.wiliki lang.wiliki pdumpfs.wiliki coLinux.wiliki \
                  lftp.wiliki backup.wiliki arrayingaush.wiliki
outfiles	= $(infiles:.wiliki=.html)


all: $(outfiles)

clean:
	rm *.html

up: update
update: commit
	git push origin master

co: commit
commit:
	-git commit -m "`date +'%F-%R'`" -a

.SUFFIXES: .wiliki .html

.wiliki.html:
	$(CV) $(cvflags) $< $@

