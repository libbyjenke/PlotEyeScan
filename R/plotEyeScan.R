#' PlotEyeScan - Visualize Eye-Tracking Fixations on Stimulus Images
#'
#' This function visualizes eye-tracking fixation data overlaid on a stimulus image. It plots fixation points, the order of fixations, and their durations, providing an intuitive way to analyze gaze behavior during experiments.
#'
#' @description
#' The `PlotEyeScan` function generates a plot with fixation data (x, y coordinates and durations) overlaid on a stimulus image. It scales the fixation points to match the dimensions of the stimulus image, and adjusts the size of fixation points based on their duration. It also manages overlapping fixation points, showing labels only for the longer fixation if two points are too close.
#'
#' @param fix_data A data frame containing fixation data with at least the following columns:
#' \itemize{
#'   \item \code{fixX}: X coordinate of the fixation on the eyetracker screen.
#'   \item \code{fixY}: Y coordinate of the fixation on the eyetracker screen.
#'   \item \code{fixDuration}: Duration of the fixation in milliseconds.
#'   \item \code{trial_num}: Trial number for each fixation.
#'   \item \code{subjID}: Subject ID for each fixation.
#' }
#' @param image_path A character string specifying the file path to the stimulus image to be used in the plot.
#' @param eyetracker_width The width of the eyetracker screen in pixels.
#' @param eyetracker_height The height of the eyetracker screen in pixels.
#' @param trial_num An integer specifying the trial number to focus on for the plot.
#' @param output_path A character string specifying the file path template where the resulting plot images will be saved. The template should include placeholders \code{<subjID>} and \code{<trial_num>} for subject ID and trial number, respectively.
#' @param overlap_threshold A numeric value (default is 50) that specifies the minimum distance (in pixels) between fixation points to determine overlap. If two fixations are closer than this threshold, only the longer fixation will display its label.
#'
#' @return This function generates and saves a series of plots as image files (e.g., PNG or JPEG) for each subject and trial, with fixation points, their order, and durations visualized on the stimulus image.
#'
#' @import ggplot2
#' @import grid
#' @import grDevices
#' @import scales
#' @import magick
#' @import stats
#'
#' @export
#'
PlotEyeScan <- function(fix_data, image_path, eyetracker_width, eyetracker_height, trial_num, output_path, overlap_threshold = 50) {

  # Read in the stimulus image
  stimulus_screen <- image_read(image_path)

  # Get dimensions of the image
  img_info <- image_info(stimulus_screen)
  img_width <- img_info$width
  img_height <- img_info$height

  # Scale fixation points to fit image dimensions
  fix_data$fixX_img <- fix_data$fixX * (img_width / eyetracker_width)
  fix_data$fixY_img <- fix_data$fixY * (img_height / eyetracker_height)

  # Print image dimensions and check range of fixation points
  cat("Image width:", img_width, "Image height:", img_height, "\n")
  cat("Fixation X range:", range(fix_data$fixX_img), "\n")
  cat("Fixation Y range:", range(fix_data$fixY_img), "\n")

  # Convert image to a raster object for ggplot
  img_grob <- rasterGrob(stimulus_screen, interpolate = TRUE)

  # Filter data for the specified trial number
  trial_data <- fix_data[fix_data$trial_num == trial_num, ]

  # Define subjects
  subject <- unique(trial_data$subjID)

  # Plot for each subject in the specified trial
  for (subjID in subject) {
    subj_data <- trial_data[trial_data$subjID == subjID, ]

    # Create fixation order from sequence of rows
    subj_data$fix_order <- seq_along(subj_data$fixX_img)

    # Check if the data contains a fixation duration (fixDuration)
    if (!"fixDuration" %in% colnames(subj_data)) {
      stop("The fixation data must include a column called 'fixDuration' with the fixation durations (in ms).")
    }

    # Scale the fixation duration for point size (you can adjust this scaling factor)
    subj_data$fix_size <- scales::rescale(subj_data$fixDuration, to = c(1, 10))  # Scale size from 1 to 10

    # Calculate pairwise distances between fixations to determine overlap
    distance_matrix <- as.matrix(dist(cbind(subj_data$fixX_img, subj_data$fixY_img)))

    # Create a vector to track which fixation points should display labels
    label_positions <- rep(TRUE, nrow(subj_data))

    # Loop through the distance matrix and determine which points overlap
    for (i in 1:(nrow(subj_data) - 1)) {
      for (j in (i + 1):nrow(subj_data)) {
        if (distance_matrix[i, j] < overlap_threshold) {
          # If the fixations are too close, compare their durations
          if (subj_data$fixDuration[i] < subj_data$fixDuration[j]) {
            # Mark the first point as not showing the label
            label_positions[i] <- FALSE
          } else {
            # Mark the second point as not showing the label
            label_positions[j] <- FALSE
          }
        }
      }
    }

    # Create a ggplot with image and fixation points
    plot <- ggplot() +
      # Add image to plot
      annotation_custom(img_grob, xmin = 0, xmax = img_width, ymin = 0, ymax = img_height) +
      # Add lines connecting fixations with color gradient based on order
      geom_path(data = subj_data, aes(x = fixX_img, y = fixY_img, color = fix_order), size = .5, lineend = "round") +
      # Add fixations as points with size based on the duration of the fixation
      geom_point(data = subj_data, aes(x = fixX_img, y = fixY_img, color = fix_order, size = fix_size)) +
      # Add fixation numbers as text labels inside the circles, checking the overlap condition
      geom_text(data = subj_data[label_positions, ], aes(x = fixX_img, y = fixY_img, label = fix_order),
                color = "black", size = 3, fontface = "bold") +  # Black text inside circles
      # Use a rainbow color scale for the lines and points
      scale_color_gradientn(colors = rainbow(7)) +  # rainbow palette with 7 colors
      # Adjust the size scale for the points
      scale_size_continuous(range = c(1, 10)) +  # Adjust range as needed
      # Change the legend title
      labs(color = "Fixation Order", size = "Fixation Duration") +
      # Remove axis labels and ticks
      theme_void() +
      # Remove margins so image fits perfectly
      theme(plot.margin = margin(0, 0, 0, 0)) +
      # Set plot limits to match image dimensions
      xlim(0, img_width) +
      ylim(0, img_height) +
      # Use coord_fixed to maintain aspect ratio
      coord_fixed(ratio = 1, xlim = c(0, img_width), ylim = c(0, img_height)) +
      # Remove size legend
      guides(size="none")

    print(plot)

    # Save the plot as an image with the subject ID and trial number in the filename
    output_filename <- gsub("\\{subjID\\}", subjID, output_path)
    output_filename <- gsub("\\{trial_num\\}", trial_num, output_filename)

    # Save the plot
    ggsave(output_filename, plot = plot, width = img_width / 100, height = img_height / 100, units = "in", dpi = 300)
  }
}
