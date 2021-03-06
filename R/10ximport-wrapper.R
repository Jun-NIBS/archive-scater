#' Load in data from 10x experiment
#' 
#' Creates a full or sparse matrix from a sparse data matrix provided by 10X 
#' genomics.
#' 
#' @param data_dir Directory containing the matrix.mtx, genes.tsv, and barcodes.tsv
#' files provided by 10x. A vector or named vector can be given in order to load 
#' several data directories. If a named vector is given, the cell barcode names 
#' will be prefixed with the name.
#' @param min_total_cell_counts integer(1) threshold such that cells (barcodes)
#' with total counts below the threshold are filtered out
#' @param min_mean_gene_counts numeric(1) threshold such that genes with mean 
#' counts below the threshold are filtered out.
#' @param ... passed arguments
#' 
#' @details This function was developed from the \code{Read10X} function from 
#' the \code{Seurat} package.
#' 
#' @return If \code{expand} is TRUE, returns an SCESet object with counts data 
#' and log2(cpm + offset) as expression data; else returns a sparse matrix with 
#' rows and columns labeled.
#' 
#' @importFrom Matrix readMM
#' @rdname read10xResults
#' @aliases read10xResults read10XResults
#' @export
#' @examples 
#' \dontrun{
#' sce10x <- read10Xxesults("path/to/data/directory")
#' count_matrix_10x <- read10xResults("path/to/data/directory", expand = FALSE)
#' }
read10xResults <- function(data_dir, min_total_cell_counts = NULL, 
                           min_mean_gene_counts = NULL) { 

    nsets <- length(data_dir)
    full_data <- vector("list", nsets)
    gene_info_list <- vector("list", nsets)
    cell_info_list <- vector("list", nsets)
    
    for (i in seq_len(nsets)) { 
        run <- data_dir[i]
        barcode.loc <- file.path(run, "barcodes.tsv")
        gene.loc <- file.path(run, "genes.tsv")
        matrix.loc <- file.path(run, "matrix.mtx")
        
        ## read sparse count matrix
        data_mat <- Matrix::readMM(matrix.loc)
        
        ## define filters
        if (!is.null(min_total_cell_counts)) { 
            keep_barcode <- (Matrix::colSums(data_mat) >= min_total_cell_counts)
            data_mat <- data_mat[, keep_barcode]
        }
         
        cell.names <- utils::read.table(barcode.loc, header = FALSE, 
                                 colClasses = "character")[[1]]
        dataset <- i
        if (!is.null(names(data_dir))) {
            dataset <- names(data_dir)[i]
        }
        
        full_data[[i]] <- data_mat
        gene_info_list[[i]] <- utils::read.table(gene.loc, header = FALSE, 
                                                 colClasses = "character")
        cell_info_list[[i]] <- DataFrame(dataset = dataset, barcode = cell.names)
    }
   
    # Checking gene uniqueness. 
    if (nsets > 1 && length(unique(gene_info_list)) != 1L) {
        stop("gene information differs between runs")
    }
    gene_info <- gene_info_list[[1]]
    colnames(gene_info) <- c("id", "symbol")
    rownames(gene_info) <- gene_info$id

    # Forming the full data matrix.
    full_data <- do.call(cbind, full_data)
    rownames(full_data) <- gene_info$id

    # Applying some filtering if requested.
    if (!is.null(min_mean_gene_counts)) {
        keep_gene <- (Matrix::rowSums(data_mat) >= min_mean_gene_counts)
        full_data <- full_data[keep_gene,]
        gene_info <- gene_info[keep_gene,]
    }
    
    # Adding the cell data.
    cell_info <- do.call(rbind, cell_info_list)
    SingleCellExperiment(list(counts = full_data), rowData = gene_info, 
                         colData = cell_info)
}


#' @rdname read10xResults
#' @export
read10XResults <- function(...) {
    read10xResults(...)
}

