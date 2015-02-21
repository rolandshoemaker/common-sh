#!/usr/bin/python3
import json, argparse
from subprocess import Popen, PIPE, sys

QD_CMD = "/home/roland/code/python/quick-doc/quick-doc.py -ja -i"

def list_functions(qdjson):
	for b in qdjson:
		print(b["name"])
		[print("  |-> %s" % (r)) for r in b["requires"]]

def get_all_reqs(qdjson, functions):
	requirements = []
	for b in qdjson:
		if b["name"] in functions:
			requirements += b["requires"]
	return set(requirements+functions)

def run():
	parser = argparse.ArgumentParser(description="build a minified shell script from a quick-doc commented shell script with only the functions you want (and their requirements).")
	parser.add_argument("input_file")
	parser.add_argument("functions", nargs="+")
	parser.add_argument("-o", "--output-file", nargs="?", type=argparse.FileType("w"), default=sys.stdout)
	parser.add_argument("-lf", "--list-functions", action="store_true", default=False)
	args = parser.parse_args()

	qd_json = json.loads(Popen(QD_CMD.split(" ")+[args.input_file], stdout=PIPE, stderr=PIPE).communicate()[0].decode("utf-8"))

	if args.list_functions:
		list_functions(qd_json)
		exit(0)
	elif len(args.functions) > 0:
		reqs = get_all_reqs(qd_json, args.functions)
		args.output_file.write("\n\n".join(["\n".join(b["source"]) for b in qd_json if b["name"] in reqs]))


if __name__ == "__main__":
	run()
