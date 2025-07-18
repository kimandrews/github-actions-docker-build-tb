FROM nextstrain/base:latest

RUN apt-get update

# Install binary deps that are packaged by Debian
RUN apt-get install --assume-yes --no-install-recommends \
    bcftools \
    bwa \
    freebayes \
    libbio-perl-perl \
    minimap2 \
    openjdk-17-jre-headless \
    parallel \
    samclip \
    samtools \
    snpeff \
    sra-toolkit \
    trimmomatic

# Update `pip` and install Python dependencies
RUN pip install --upgrade pip
RUN pip install \
    docxtpl \
    filelock \
    pydantic \
    pysam \
    rich_argparse \
    tomli \
    tqdm

# Check out packages we want to build from source
RUN git clone https://github.com/jodyphelan/itol-config           /opt/itol-config
RUN git clone https://github.com/jodyphelan/pathogen-profiler.git /opt/pathogen-profiler
RUN git clone https://github.com/jodyphelan/TBProfiler.git        /opt/TBProfiler
RUN git clone https://github.com/tseemann/snippy.git              /opt/snippy

# apply monkey patch to pathogen-profiler
COPY pathogen-profiler.patch /tmp/pathogen-profiler.patch
RUN pushd /opt/pathogen-profiler && \
    git apply /tmp/pathogen-profiler.patch && \
    rm /tmp/pathogen-profiler.patch && \
    popd

# Build/install those things
RUN pushd /opt/itol-config       && pip install . && popd
RUN pushd /opt/pathogen-profiler && pip install . && popd
RUN pushd /opt/TBProfiler        && pip install . && popd

# Set up tb-profiler run area and the one file it won't bootstrap
RUN mkdir -p /usr/local/share/tbprofiler/snpeff && \
    touch /usr/local/share/tbprofiler/snpeff/snpEff.config && \
    chmod -R 777 /usr/local/share/tbprofiler

# Uncomment this if you need a persistent entrypoint so you can shell into the container
# CMD tail -f /dev/null
