import os
import subprocess
import json
import sys

import numpy as np
import matplotlib as mpl
mpl.use("Agg")
import matplotlib.pyplot as plt

class DockerApp:
    def __init__(self):
        appconf = "/data/input/AppSession.json" if len(sys.argv) == 1 \
          else sys.argv[1]
        jf = json.load(open(appconf))
        properties = jf["Properties"]["Items"]
        properties = dict(zip([p["Name"] for p in properties], properties))

        self.InAppResultID = properties["Input.AppResults"]["Items"][0]["Id"]
        self.methfile = properties["Input.meth-file"]["Content"]["Path"]
        self.desertSize = properties["Input.desert-size"]["Content"]
        self.numIter = properties["Input.num-iter"]["Content"]
        self.outProjID = properties["Input.project-id"]["Content"]["Id"]
        self.computePMD = "-partial" if "Input.do-pmd" in properties else ""
        self.verbose = "-verbose"

        self.app = "/home/methpipe/methpipe/bin/hmr"
        self.infile = "/data/input/appresults/" + self.InAppResultID \
          + "/" + self.methfile
        self.outfile = "/data/output/appresults/" + self.outProjID \
          + "/HMRs/" + self.methfile.replace(".meth", ".hmr")

    def gen_reports(self):
        chroms = list()
        hmr_lens = list()
        hmr_cpgs = list()
        for l in open(self.outfile):
            f = l.split()
            chroms.append(f[0])
            hmr_lens.append(int(f[2]) - int(f[1]))
            hmr_cpgs.append(int(f[4]))

        # bar plot for hmr number in each chromosome
        chrom_counts = dict()
        for c in chroms:
            if c in chrom_counts:
                chrom_counts[c] += 1
            else:
                chrom_counts[c] = 0
        chroms = chrom_counts.keys()
        chrom = chroms.sort(key = lambda c: ("0" + c[2:]) if c[2:] in [str(i) for i in range(10)] else c[2:])
        plt.bar(np.arange(len(chroms)),  [chrom_counts[c] for c in chroms], 0.8)
        plt.xticks(np.arange(len(chroms)) + 0.4, chroms, rotation = 90)
        plt.savefig(self.outfile + ".hmr_by_chrom.png", format = "png")
        plt.close()

        # histogram for hmr size
        plt.hist(hmr_lens, bins = 20)
        plt.savefig(self.outfile + ".hmr_lens.png", format = "png")
        plt.close()

        # histogram for hmr size
        plt.hist([hmr_cpgs[i] * 1.0 / hmr_lens[i] for i in range(len(hmr_lens))], bins = 20)
        plt.savefig(self.outfile + ".hmr_CpG_density.png", format = "png")
        plt.close()

    def run(self):
        outdir = os.path.dirname(self.outfile)
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        command_list = [self.app, self.infile, "-itr", self.numIter, \
                        "-desert", self.desertSize, \
                        "-out", self.outfile, self.verbose]
        if self.computePMD: command_list.append(self.computePMD)
        print "\t".join(command_list)
        rcode = subprocess.call( command_list )
        if rcode != 0 : raise Exception("Exited abnormally")
        self.gen_reports()
            
#the entry point
if __name__ == "__main__" :
    DockerApp().run()


    
