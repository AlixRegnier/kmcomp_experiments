from utils import *
from plotnine import *
import pandas as pd

BLOCKSIZE = [65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608]
STR_BLOCKSIZE = ["64kB", "128kB", "256kB", "512kB", "1MB", "2MB", "4MB", "8MB"]

value_name = "time(s)"

types = ["ECOLI", "SENTERICA", "HUMANGUT"]

ddf = { "blocksize": [], "querysize": [], "shape": [], "color": [], "value": [], "curve": [] }

DICT_BSIZE = dict(zip(BLOCKSIZE, STR_BLOCKSIZE))

for type in types:
    for bsize in BLOCKSIZE:
        for qsize in [150, 150000]:
            s_uncompressed = []
            s = []
            for x in range(1,5):
                d_uncompressed = get_dict_from_json(f"./usage/query/{type}_query2_f{qsize}_{DICT_BSIZE[bsize]}_{x}_uncompressed.txt")
                s_uncompressed.append(d_uncompressed[value_name])
                
                d = get_dict_from_json(f"./usage/query/{type}_query2_f{qsize}_{DICT_BSIZE[bsize]}_{x}.txt")
                s.append(d[value_name])

            #π-compressed
            ddf["blocksize"].append(bsize)
            ddf["querysize"].append(qsize)
            ddf["shape"].append("π-compressed")
            ddf["color"].append(type)
            ddf["value"].append(sum(s)/len(s))
            ddf["curve"].append(f"{type}_{qsize}")
            
            #Not compressed
            ddf["blocksize"].append(bsize)
            ddf["querysize"].append(qsize)
            ddf["shape"].append("not compressed")
            ddf["color"].append(type)
            ddf["value"].append(sum(s_uncompressed)/len(s_uncompressed))
            ddf["curve"].append(f"{type}_{qsize}_uncompressed")


# Sample data
df = pd.DataFrame(ddf)

df['value_label'] = df['value'].apply(time_label)
df['querysize'] = df['querysize'].apply(str)


plot = (
    ggplot(df, aes(x='blocksize', y='value', color='color', shape="shape", group="curve", linetype="querysize")) +
    geom_line(size=1) +
    geom_point(size=3) +
    geom_text(
        mapping=aes(label='value_label'),
        size=8,
        fontweight="semibold",
        va='bottom',
        color="black"
    ) +
    scale_shape_manual(values=['^', 'o']) +
    scale_color_manual(palette_3) +
    theme_light() +
    scale_x_log10(breaks=BLOCKSIZE, labels=STR_BLOCKSIZE) +
    scale_y_log10(labels=lambda x: [time_label(val) for val in x]) + 
    facet_wrap("color", ncol=1, scales="free_y") +
    labs(x='Block size (logarithmic)', y='Query time (s)', fill="Dataset", color="Dataset", shape="Compression")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/query_time_vs_type_x_blocksize.pdf")