import os
import subprocess
import json
import sys

class DockerApp:
    def __init__(self):
        appconf = "/data/input/AppSession.json" if len(sys.argv) == 1 \
          else sys.argv[1]
        jf = json.load(open(appconf))
        properties = jf["Properties"]["Items"]
        properties = dict(zip([p["Name"] for p in properties], properties))

        self.app = "/home/methpipe/methpipe/bin/rmapbs"

        self.InAppResultID = properties["Input.AppResults"]["Items"][0]["Id"]

        self.genomeFile = properties["Input.genome-file"]["Content"]["Path"]
        self.genomeFile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.genomeFile

        self.readFile = properties["Input.fastq-file"]["Content"]["Path"]
        self.readFile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.readFile

        self.start_read = properties["Input.index-first-read"]["Content"]
        self.num_read = properties["Input.num-read"]["Content"]

        self.max_mismatch = properties["Input.max-mismatch"]["Content"]
        self.max_map = properties["Input.max-mapping-locs"]["Content"]
        
        self.adapter = "" if not "Input.adapter-seq" in properties else \
          properties["Input.adapter-seq"]["Content"]

        self.verbose = "-verbose"

        self.outProjID = properties["Input.project-id"]["Content"]["Id"]

        self.mappedReadFile = self.readFile.replace(".fq", ".mr")
        self.mappedReadFile = self.mappedReadFile.replace( \
            "/data/input/appresults/" + self.InAppResultID + "/", \
            "/data/output/appresults/" + self.outProjID + "/mapped/")
          
    def run(self):
        command_list = [self.app, self.readFile, \
                        "-output", self.mappedReadFile, \
                        "-chrom", self.genomeFile, \
                        "-start", self.start_read, \
                        "-number", self.num_read, \
                        "-mismatch", self.max_mismatch, \
                        "-max-map", self.max_map, \
                        self.verbose]
        if self.adapter: command_list.extend(["-clip", self.adapter])
        print "\t".join(command_list)
        outdir = os.path.dirname(self.mappedReadFile)
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("Exited abnormally")

#the entry point
if __name__ == "__main__" :
    DockerApp().run()


    
