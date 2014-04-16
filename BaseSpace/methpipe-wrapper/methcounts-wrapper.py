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

        self.app = "/home/methpipe/methpipe/bin/methcounts"
        
        self.InAppResultID = properties["Input.AppResults"]["Items"][0]["Id"]
        self.genomefile = properties["Input.genome-file"]["Content"]["Path"]
        self.genomefile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.genomefile

        self.mappedReadFile = properties["Input.mr-file"]["Content"]["Path"]
        self.mappedReadFile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.mappedReadFile

        self.maxReadLen = properties["Input.max-read-length"]["Content"]
        self.maxMismatches = properties["Input.max-mismatch"]["Content"]

        self.nonCpG = "-non" if "Input.non-CpG" in properties else ""
        self.verbose = "-verbose"
        
        self.outProjID = properties["Input.project-id"]["Content"]["Id"]

        self.methfile = "/data/output/appresults/" + self.outProjID \
          + "/" + self.mappedReadFile.replace(".mr", ".meth")
          
    def run(self):
        outdir = os.path.dirname(self.methfile)
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        command_list = [self.app, "-output", self.methfile, \
                        "-chrom", self.genomefile, self.nonCpG, \
                        "-max_length", self.maxReadLen, \
                        "-max", self.maxMismatches, self.verbose, \
                        self.mappedReadFile]
        print "\t".join(command_list)
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("fastqc process exited abnormally")

#the entry point
if __name__ == "__main__" :
    DockerApp().run()


    
