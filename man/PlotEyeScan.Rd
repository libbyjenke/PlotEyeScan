% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotEyeScan.R
\name{PlotEyeScan}
\alias{PlotEyeScan}
\title{PlotEyeScan - Visualize Eye-Tracking Fixations on Stimulus Images}
\usage{
PlotEyeScan(
  fix_data,
  image_path,
  eyetracker_width,
  eyetracker_height,
  trial_num,
  output_path,
  overlap_threshold = 50
)
}
\arguments{
\item{fix_data}{A data frame containing fixation data with at least the following columns:
\itemize{
\item \code{fixX}: X coordinate of the fixation on the eyetracker screen.
\item \code{fixY}: Y coordinate of the fixation on the eyetracker screen.
\item \code{fixDuration}: Duration of the fixation in milliseconds.
\item \code{trial_num}: Trial number for each fixation.
\item \code{subjID}: Subject ID for each fixation.
}}

\item{image_path}{A character string specifying the file path to the stimulus image to be used in the plot.}

\item{eyetracker_width}{The width of the eyetracker screen in pixels.}

\item{eyetracker_height}{The height of the eyetracker screen in pixels.}

\item{trial_num}{An integer specifying the trial number to focus on for the plot.}

\item{output_path}{A character string specifying the file path template where the resulting plot images will be saved. The template should include placeholders \code{<subjID>} and \code{<trial_num>} for subject ID and trial number, respectively.}

\item{overlap_threshold}{A numeric value (default is 50) that specifies the minimum distance (in pixels) between fixation points to determine overlap. If two fixations are closer than this threshold, only the longer fixation will display its label.}
}
\value{
This function generates and saves a series of plots as image files (e.g., PNG or JPEG) for each subject and trial, with fixation points, their order, and durations visualized on the stimulus image.
}
\description{
The \code{PlotEyeScan} function generates a plot with fixation data (x, y coordinates and durations) overlaid on a stimulus image. It scales the fixation points to match the dimensions of the stimulus image, and adjusts the size of fixation points based on their duration. It also manages overlapping fixation points, showing labels only for the longer fixation if two points are too close.
}
\details{
This function visualizes eye-tracking fixation data overlaid on a stimulus image. It plots fixation points, the order of fixations, and their durations, providing an intuitive way to analyze gaze behavior during experiments.
}
