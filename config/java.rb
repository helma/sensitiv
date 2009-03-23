# modify your java location below
ENV['JAVA_HOME'] = '/usr/lib/jvm/java-1.5.0-sun'
ENV['LD_LIBRARY_PATH'] =  ENV['JAVA_HOME'] + '/jre/lib/i386' + ':' + ENV['JAVA_HOME'] + '/jre/lib/i386/client'
