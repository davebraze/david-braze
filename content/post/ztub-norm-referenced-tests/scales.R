library(ggplot2)
library(dplyr)
library(FDBpub)

scales.cap <- "This figure shows a normal distribution (a.k.a., a bell curve). Blue and yellow shaded bands within the curve are each 1 standard deviation (SD) in width. Note that the 6 SD bands are all equal in width. Each “ruler” below the curve shows how a different normative score type (Percentile/Decile, Stanine, \\& Standard Score) relates to the normal distribution, and to each other. Note that percentiles and stanines have a non-linear relationship to SDs, while standard scores have a linear relationship to SDs."

caption.scales <- paste("Figure by David Braze (davebraze@gmail.com) using R statistical software,",
                       "Released under the Creative Commons v4.0 CC-by license.",
                       sep="\n")


x <- seq(-3, 3, by = .01)
dd <-
    data.frame(sd=x,
               density=dnorm(x, mean = 0, sd = 1)) %>%
    mutate(std.score=round(sd*15+100),
           ## set nce to NA if (nce<0 || nce>100)
           nce.score = sd*21.06+50,
           prob = pnorm(sd),
           sd.n = case_when(sd < 0 ~ floor(sd)+4,
                            sd > 0 ~ ceiling(sd)+3,
                            sd == 0 ~ 4),
           pr.score = case_when(prob <= 0.5 ~ ceiling(prob*100),
                                prob > 0.5 ~ floor(prob*100)),
           quartiles = case_when(prob <= 1/4 ~ 1L,
                                 prob <= 2/4 ~ 2L,
                                 prob <= 3/4 ~ 3L,
                                 prob > 3/4 ~ 4L),
           stanines = case_when(prob <= 1/9 ~ 1L,
                                prob <= 2/9 ~ 2L,
                                prob <= 3/9 ~ 3L,
                                prob <= 4/9 ~ 4L,
                                prob <= 5/9 ~ 5L,
                                prob <= 6/9 ~ 6L,
                                prob <= 7/9 ~ 7L,
                                prob <= 8/9 ~ 8L,
                                prob > 8/9 ~ 9L),
           deciles = case_when(prob <= 1/10 ~ 1L,
                               prob <= 2/10 ~ 2L,
                               prob <= 3/10 ~ 3L,
                               prob <= 4/10 ~ 4L,
                               prob <= 5/10 ~ 5L,
                               prob <= 6/10 ~ 6L,
                               prob <= 7/10 ~ 7L,
                               prob <= 8/10 ~ 8L,
                               prob <= 9/10 ~ 9L,
                               prob > 9/10 ~ 10L)
           )

clr <- c("mistyrose",
         "powderblue",
         "lemonchiffon",
         "lavender"
         )


## normal dist with standard deviations marked (±3)
scale.plt.0  <-
    dd %>%
    ggplot(aes(x=sd, y=density)) +
    geom_area(data=filter(dd, sd.n==1), fill=clr[1]) +
    geom_area(data=filter(dd, sd.n==2), fill=clr[2]) +
    geom_area(data=filter(dd, sd.n==3), fill=clr[1]) +
    geom_area(data=filter(dd, sd.n==4), fill=clr[2]) +
    geom_area(data=filter(dd, sd.n==5), fill=clr[1]) +
    geom_area(data=filter(dd, sd.n==6), fill=clr[2]) +
    geom_line() +
    scale_x_continuous(breaks = NULL, name="Score Quality") +
    scale_y_continuous(breaks = NULL, name="Score Probability", limits = c(-0.15, NA)) +
    labs(caption = caption.scales) +
    theme_minimal() +
    theme(plot.caption = element_text(size = rel(.6), color = "grey20"))

## add decile/percentile strip
line <- 1
ymax <- -.01
height <- .03
ymin <- ymax - (height * line)
scale.plt.q  <-
    scale.plt.0 +
    geom_ribbon(data=filter(dd, deciles==1),
                aes(ymax=ymax, ymin=ymin, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, deciles==1),
              aes(x=min(sd), y=ymin, label="Percentiles"),
                inherit.aes=FALSE,
              nudge_x = .35, nudge_y = .015,
              size=3, color="black") +
    geom_text(data=filter(dd, deciles==1),
              aes(x=mean(range(sd)), y=ymin, label="1-10"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==2),
                aes(ymax=ymax, ymin=ymin, x=sd),
                fill=clr[4]) +
    geom_text(data=filter(dd, deciles==2),
              aes(x=mean(range(sd)), y=ymin, label="11-20"),
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==3),
                aes(ymax=ymax, ymin=ymin, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, deciles==3),
              aes(x=mean(range(sd)), y=ymin, label="21-30"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==4),
                aes(ymax=ymax, ymin=ymin, x=sd),
                fill=clr[4]) +
    geom_text(data=filter(dd, deciles==4),
              aes(x=mean(range(sd)), y=ymin, label="31-40"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==5),
                aes(ymax=ymax, ymin=ymin, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, deciles==5),
              aes(x=mean(range(sd)), y=ymin, label="41-50"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==6),
                aes(ymax=ymax, ymin=ymin),
                fill=clr[4]) +
    geom_text(data=filter(dd, deciles==6),
              aes(x=mean(range(sd)), y=ymin, label="51-60"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==7),
                aes(ymax=ymax, ymin=ymin),
                fill=clr[3]) +
    geom_text(data=filter(dd, deciles==7),
              aes(x=mean(range(sd)), y=ymin, label="61-70"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==8),
                aes(ymax=ymax, ymin=ymin),
                fill=clr[4]) +
    geom_text(data=filter(dd, deciles==8),
              aes(x=mean(range(sd)), y=ymin, label="71-80"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==9),
                aes(ymax=ymax, ymin=ymin),
                fill=clr[3]) +
    geom_text(data=filter(dd, deciles==9),
              aes(x=mean(range(sd)), y=ymin, label="81-90"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, deciles==10),
                aes(ymax=ymax, ymin=ymin),
                fill=clr[4]) +
    geom_text(data=filter(dd, deciles==10),
              aes(x=mean(range(sd)), y=ymin, label="91+"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black")

## add stanine strip
line2 <- 1.1
height <- .03
ymax2 <- -.01 - (height * line2)
ymin2 <- ymax2 - height
scale.plt.q  <-
    scale.plt.q +
    geom_ribbon(data=filter(dd, stanines==1),
                aes(ymax=ymax2, ymin=ymin2, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, stanines==1),
              aes(x=min(sd), y=ymin2, label="Stanines"),
                inherit.aes=FALSE,
              nudge_x = .3, nudge_y = .0175,
              size=3, color="black") +
    geom_text(data=filter(dd, stanines==1),
              aes(x=mean(range(sd)), y=ymin2, label="1"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==2),
                aes(ymax=ymax2, ymin=ymin2, x=sd),
                fill=clr[4]) +
    geom_text(data=filter(dd, stanines==2),
              aes(x=mean(range(sd)), y=ymin2, label="2"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==3),
                aes(ymax=ymax2, ymin=ymin2, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, stanines==3),
              aes(x=mean(range(sd)), y=ymin2, label="3"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==4),
                aes(ymax=ymax2, ymin=ymin2, x=sd),
                fill=clr[4]) +
    geom_text(data=filter(dd, stanines==4),
              aes(x=mean(range(sd)), y=ymin2, label="4"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==5),
                aes(ymax=ymax2, ymin=ymin2, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, stanines==5),
              aes(x=mean(range(sd)), y=ymin2, label="5"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==6),
                aes(ymax=ymax2, ymin=ymin2),
                fill=clr[4]) +
    geom_text(data=filter(dd, stanines==6),
              aes(x=mean(range(sd)), y=ymin2, label="6"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==7),
                aes(ymax=ymax2, ymin=ymin2),
                fill=clr[3]) +
    geom_text(data=filter(dd, stanines==7),
              aes(x=mean(range(sd)), y=ymin2, label="7"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==8),
                aes(ymax=ymax2, ymin=ymin2),
                fill=clr[4]) +
    geom_text(data=filter(dd, stanines==8),
              aes(x=mean(range(sd)), y=ymin2, label="8"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, stanines==9),
                aes(ymax=ymax2, ymin=ymin2),
                fill=clr[3]) +
    geom_text(data=filter(dd, stanines==9),
              aes(x=mean(range(sd)), y=ymin2, label="9"),
                inherit.aes=FALSE,
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black")

## ## add Standard Score strip
line3 <- 2.2
height <- .03
ymax3 <- -.01 - (height * line3)
ymin3 <- ymax3 - height
scale.plt.q  <-
    scale.plt.q +
    geom_ribbon(data=filter(dd, sd.n==1), inherit.aes=FALSE,
                aes(ymax=ymax3, ymin=ymin3, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, sd.n==1),
              aes(x=min(sd), y=ymin3, label="Std. Scores"),
              nudge_x = .35, nudge_y = .0175,
              size=3, color="black") +
    geom_text(data=filter(dd, sd.n==1),
              aes(x=mean(range(sd)), y=ymin3, label="55-70"),
              vjust = "bottom", hjust="center",
              nudge_x = .35, nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, sd.n==2), inherit.aes=FALSE,
                aes(ymax=ymax3, ymin=ymin3, x=sd),
                fill=clr[4]) +
    geom_text(data=filter(dd, sd.n==2),
              aes(x=mean(range(sd)), y=ymin3, label="71-85"),
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, sd.n==3), inherit.aes=FALSE,
                aes(ymax=ymax3, ymin=ymin3, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, sd.n==3),
              aes(x=mean(range(sd)), y=ymin3, label="86-100"),
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, sd.n==4), inherit.aes=FALSE,
                aes(ymax=ymax3, ymin=ymin3, x=sd),
                fill=clr[4]) +
    geom_text(data=filter(dd, sd.n==4),
              aes(x=mean(range(sd)), y=ymin3, label="101-115"),
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, sd.n==5), inherit.aes=FALSE,
                aes(ymax=ymax3, ymin=ymin3, x=sd),
                fill=clr[3]) +
    geom_text(data=filter(dd, sd.n==5),
              aes(x=mean(range(sd)), y=ymin3, label="116-130"),
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black") +
    geom_ribbon(data=filter(dd, sd.n==6), inherit.aes=FALSE,
                aes(ymax=ymax3, ymin=ymin3, x=sd),
                fill=clr[4]) +
    geom_text(data=filter(dd, sd.n==6),
              aes(x=mean(range(sd)), y=ymin3, label="131-145"),
              vjust = "bottom", hjust="center",
              nudge_y=.01,
              size=2.25, color="black")

ggsave("normal.png", scale.plt.q,
       dev=png, type="cairo-png",
       width = 16*.45, height = 9*.45)
