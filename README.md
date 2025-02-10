<h1>PlotEyeScan</h1>

<b>PlotEyeScan</b> is an R package for visualizing eye tracking data. This package allow researchers to visualize eye-tracking fixation data on stimulus images. It provides a function that overlays fixation points, their order, and their durations onto a stimulus image. The package adjusts the size of fixation points based on their duration (bigger = longer) and handles overlapping fixations by hiding labels for shorter fixations. It outputs high-quality plots for each subject and trial, which can be saved as image files for further analysis and interpretation.


<h2>Installation and Setup</h2>
To install the development version from GitHub, use the following command: 

```r
devtools::install_github("libbyjenke/PlotEyeScan")
```

Once it is installed, load the package using:
```{r setup}
library(PlotEyeScan)
```

<h2>Basic Usage Example</h2>

This example comes from Jenke & Sullivan (forthcoming, *Political Analysis*). We will use the data, **sample_data**, which is in the package.

The data contain eye tracking data for three participants on one stimulus screen. 

```{r loaddata}
data(sample_data, package="PlotEyeScan")
head(sample_data)
```

Let's plot the data using **PlotEyeScan**. To do this, we need to define seven parameters: fix_data, image_path, eyetracker_width, eyetracker_height, trial_num, output_path, and overlap threshold.

**fix_data**: The fixation data needs to contain the following variables: fixX (X coordinates of the fixations on the eye tracker screen), fixY (Y coordinate of the fixation on the eyetracker screen), fixDuration (duration of the fixation in milliseconds), trial_num (trial number for each fixation), and subjID (subject ID for each fixation).

**image_path**: This is the path to the stimulus image, which is also in the package. This image must be as it was shown on the eye tracker screen; its orientation and size compared to the eye tracking screen must be correctly represented. For example, if showing a portrait-oriented image on a landscape-oriented eye tracker, there will be margins on either side of the image that must be incorporated into the stimulus image dimensions. Otherwise, the scaling factor to match the image with the fixations will be incorrect.

**eyetracker_width** and **eyetracker_height**: The width and height of the eye tracker's screen in pixels. This information can be found in your eyetracker's manual or on the manufacturer's website.

**trial_num**: The number of the trial that you are going to plot. This can also be set as a vector if you would like to include more than one trial.

**output_path**: A string specifying the directory and base file name where the plots will be saved. In the code below, I have defined the outpath path to include `{subjID}` and `{trial_num}` as placeholders that will be replaced by the actual subject ID and trial number.

**overlap threshold**: A numeric value (default is 50) that specifies the minimum distance (in pixels) between fixation points to determine overlap. If two fixations are closer than this threshold, only the longer fixation will display its label.

```{r plot_fixations}

# Get only necessary variables 
fix_data <- sample_data[, c("Respondent.Name","Fixation.X","Fixation.Y","trial_num","Fixation.Duration")]

# And rename variables
fix_data <- fix_data |>
  rename(
    fixX = `Fixation.X`,
    fixY = `Fixation.Y`,
    subjID = `Respondent.Name`,
    fixDuration = `Fixation.Duration`
  )

# Define path to stimulus image
image_path <- readPNG(system.file("data", "stimulus_screen.png", package = "PlotEyeFix"))

# Define width and height of eye tracker
eyetracker_width <- 1920
eyetracker_height <- 1080

# Define trial of interest
trial_num <- 1

# Define output path
output_path <- file.path(tempdir(),"ET_output/{subjID}_trial_{trial_num}.png")

PlotEyeScan(fix_data, image_path, eyetracker_width, eyetracker_height, trial_num, output_path, overlap_threshold) 

```
You should now have a series of plots, each one with a single respondents' data for a single stimulus screen.

You can see that Respondent 2's fixations are down and to the right of where they would be expected if the respondent were looking at the stimuli. This is because the calibration step was (purposefully) not done properly, leading to an offset of the respondent's fixations.

## Applications
For a framework for applications and more on using eye tracking in the social sciences, see this paper:
Libby Jenke and Nicolette Sullivan. "Attention and Political Choice: A Foundation for Eye Tracking in Political Science." Forthcoming at *Political Analysis*. [Working paper](https://osf.io/preprints/socarxiv/ns48h),
