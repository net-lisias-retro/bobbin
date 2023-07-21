#!/usr/bin/awk -f

function o(s) {
    print "    \"" s "\\n\"";
}

BEGIN {
    STARTED=0
    print "// This file was auto-generated from the README.md,"
    print "// as part of the build process. Any changes here may"
    print "// be overwritten!"
    print
    print "// this file is read by config.c."
    print
    print "static const char help_text[] = "
}

1 {
    OUTPUT = "";
}

/^#/ {
    IN_SYNOPSIS = 0;
}

IN_SYNOPSIS && !/^$/ {
    gsub(/\*\*/,"")
    gsub(/\\/,"")
    gsub(/&lt;/,"<")
    gsub(/<br[^>]*>/,"");

    # Deal with variable params (from *var* -> VAR)
    while (i = match($0,/\*/)) {
        j = i + match(substr($0,i+1),/\*/);
        if (j == i) break;
        s = substr($0,i,j-i+1);
        t = s
        gsub(/\*/,"",t);
        t = toupper(t);
        $0 = substr($0,1,i-1) t substr($0,j+1)
    }
    o($0)
}

/^### Synopsis/ {
    IN_SYNOPSIS = 1;
}

/^<!--START-OPTIONS-->/ {
    STARTED = 1;
    o("");
}

NEED_DESC && !/^$/ {
    NEED_DESC = 0;
    gsub(/\*\*/,"");
    OUTPUT = "     " $0;
}

STARTED && /^##### / {
    NEED_DESC = 1;
    sub(/^##### /,"");
    sub(/\*arg\*/,"ARG");
    OUTPUT = "  " $0;
}

OUTPUT {
    o(OUTPUT);
}

/^<!--END-OPTIONS-->/ {
    print ";"
    exit(0);
}

