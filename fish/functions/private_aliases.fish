function :qweb_dev
	ssh deploy@web02.dev.qustodio.net $argv;
end

function :qweb_pre
	ssh deploy@web02.pre.qustodio.net $argv;
end

function :qweb_pro
	ssh ubuntu@web01.pro.qustodio.net $argv;
end
