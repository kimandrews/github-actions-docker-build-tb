FROM nextstrain/base

# sra-toolkit: https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
WORKDIR /download/sratoolkit
RUN curl https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz \
  | tar xzvpf - --no-same-owner --strip-components=1 \
 && cp -pr bin/* /usr/local/bin

# snippy
WORKDIR /snippy
RUN apt-get update && apt-get install -y --no-install-recommends perl \
 && git clone https://github.com/tseemann/snippy.git


# tbprofiler
RUN pip3 install git+https://github.com/jodyphelan/TBProfiler.git
RUN pip3 install git+https://github.com/jodyphelan/pathogen-profiler.git

# tbprofiler dependencies that are also snippy dependencies
RUN apt-get update && apt-get install -y --no-install-recommends bwa \
minimap2 \
samtools \
bcftools \
freebayes \
parallel \
samclip \
snpeff

# tbprofiler dependencies that are not already in snippy
RUN apt-get update && apt-get install -y --no-install-recommends python3-tqdm trimmomatic
RUN pip install git+https://github.com/jodyphelan/itol-config.git
RUN pip3 install pysam pydantic rich_argparse tomli docxtpl filelock

RUN tb-profiler update_tbdb
