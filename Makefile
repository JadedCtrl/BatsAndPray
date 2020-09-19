love:
	zip -9r bats\&pray.love ./*

test: love
	love bats\&pray.love

clean: 
	rm bats\&pray.love

all: love

