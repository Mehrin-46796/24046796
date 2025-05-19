#!/bin/bash


# input file name check
input_validation() {
    if [[ $# -ne 1 ]]; then
        echo "please write in the command: ./analysis filename.tsv"
        exit 1
    fi

    file_name="$1"

    if [[ "$file_name" != *.tsv ]]; then
        echo "Please input only TSV file name for analysis."
        exit 1
    fi

    if [[ ! -f "$file_name" ]]; then
        echo "file does not exist. Please input a valid TSV file name."
        exit 1
    fi
}



# relation between two columns
correlation_between() {
    file_name="$1"
    column_x="$2"
    column_y="$3"
    label="$4"

    awk -F'\t' -v cx="$column_x" -v cy="$column_y" -v des="$label" '
    BEGIN {
        sumx = sumy = sumxx = sumyy = sumxy = count = 0
    }
    NR > 1 {
        x = $cx
        y = $cy
        if (x ~ /^[0-9.]+$/ && y ~ /^[0-9.]+$/) {
            x_val = x + 0
            y_val = y + 0
            sumx += x_val
            sumy += y_val
            sumxx += x_val * x_val
            sumyy += y_val * y_val
            sumxy += x_val * y_val
            count++
        }
    }
    END {
        if (count > 1) {
            num = (count * sumxy) - (sumx * sumy)
            denominator = sqrt((count * sumxx - sumx^2) * (count * sumyy - sumy^2))
            if (denominator != 0) {
                correlation = num / denominator
                printf "%s is %.3f\n", des, correlation
            } else {
                printf "%s could not be calculated (division by zero)\n", des
            }
        } else {
            printf "Not sufficient data to calculate %s\n", des
        }
    }
    ' "$file_name"
}


# most frequent game mechanic command
find_top_mechanic() {
    awk -F'\t' '
    NR > 1 && $13 != "" {
        count = split($13, items, ". ")
        for (i = 1; i <= count; i++) {
            gsub(/^[ \t]+|[ \t]+$/, "", items[i])
            freq[items[i]]++
        }
    }
    END {
        top = "N/A"
        max_count = 0
        for (mech in freq) {
            if (freq[mech] > max_count) {
                max_count = freq[mech]
                top = mech
            }
        }
        printf "The most popular game mechanic is %s found in %d games\n", top, max_count
    }
    ' "$1"
}

#most frequent game domain command
find_top_domain() {
    awk -F'\t' '
    NR > 1 && $14 != "" {
        count = split($14, parts, ".")
        for (i = 1; i <= count; i++) {
            gsub(/^[ \t]+|[ \t]+$/, "", parts[i])
            dom[parts[i]]++
        }
    }
    END {
        if (length(dom) == 0) {
            print "The most frequent game domain is N/A found in 0 games"
            exit
        }
        max_count = 0
        top_domain = "N/A"
        for (d in dom) {
            if (dom[d] > max_count) {
                max_count = dom[d]
                top_domain = d
            }
        }
        printf "The most frequent game domain is %s found in %d games\n", top_domain, max_count
    }
    ' "$1"
}


# Main
input_validation "$@"


find_top_mechanic "$1"
find_top_domain "$1"
correlation_between "$1" 3 9 "The correlation between the year of publication and the average rating"
correlation_between "$1" 11 9 "The correlation between the complexity of a game and its average rating"
