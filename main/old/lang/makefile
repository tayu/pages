# gen html documant from sgml

CV		= wiliki2html.scm
cvflags		=

infiles		= t-install.wiliki t-hello.wiliki t-comment.wiliki \
		  t-literal.wiliki t-variable.wiliki t-sequence.wiliki \
		  t-selection.wiliki t-iterate.wiliki t-function.wiliki
outfiles	= $(infiles:.wiliki=.html)


all: $(outfiles)

clean:
	rm *.html

up: update
update: commit
	git push origin master

co: commit
commit:
	git commit -m "`date +'%F-%R'`" -a

.SUFFIXES: .wiliki .html

.wiliki.html:
	$(CV) $(cvflags) $< $@

