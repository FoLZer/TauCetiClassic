#!/usr/bin/env python3

## Reasons of this wrapper:
## 1) Byond in a bad relationship with unicode (513?)
## 2) Byond export proc does not support https (someday?)

import requests, argparse, json, os, sys

def read_arguments():
	parser = argparse.ArgumentParser(
		description="get wrapper"
	)

	parser.add_argument(
		"url",
	)

	parser.add_argument(
		"--json", type=os.fsencode
	)

	return parser.parse_args()

def main(options):

	if(options.json):
		jsonn = json.loads(byond_outer_text(options.json))

	if(options.json):
		r = requests.get(options.url, json=jsonn)
	else:
		r = requests.get(options.url)

	if(r.raise_for_status()):
		sys.exit(0)

	#sys.stdout.buffer.write(byond_inner_text(r.text))
	#print(byond_inner_text(r.text))
	#with open(".shell","w") as out:
	#	out.write(r.text)
	sys.exit(1)

def byond_outer_text(text):
	return text.decode("cp1251").replace("¶", "я").replace("'","\"")

def byond_inner_text(text):
	return text.replace("я", "¶")#.encode("cp1251", 'ignore')

if __name__ == "__main__":
	options = read_arguments()
	sys.exit(main(options))
