//! Requires blas, lapack, and llvm's openmp to be installed.
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.Build.Step.Compile.Linkage, "linkage", "Whether to link statically or dynamically (default: static)") orelse .static;
    const avx2 = b.option(bool, "avx2", "Enable avx2 instructions (default: true)") orelse true;

    const faiss = std.Build.Step.Compile.create(b, .{
        .name = "faiss",
        .root_module = .{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        },
        .kind = .lib,
        .linkage = linkage,
        .version = std.SemanticVersion{ .major = 1, .minor = 7, .patch = 4 },
    });

    faiss.addCSourceFiles(.{
        .files = &source_files,
        .flags = if (avx2)
            &.{ "-mavx2", "-mfma", "-mf16c", "-mpopcnt" }
        else
            &.{},
    });
    if (target.result.os.tag != .windows) {
        faiss.addCSourceFiles(.{ .files = &.{
            "faiss/invlists/OnDiskInvertedLists.cpp",
        } });
    }
    faiss.defineCMacro("FINTEGER", "int");
    faiss.linkSystemLibrary2("omp", .{});
    faiss.linkSystemLibrary2("blas", .{});
    faiss.linkSystemLibrary2("lapack", .{});
    faiss.addIncludePath(.{ .path = "./" });
    faiss.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "faiss" },
        .install_dir = .header,
        .install_subdir = "faiss",
        .include_extensions = &.{"h"},
    });
    b.installArtifact(faiss);
}

const source_files = [_][]const u8{
    "faiss/AutoTune.cpp",
    "faiss/Clustering.cpp",
    "faiss/IVFlib.cpp",
    "faiss/Index.cpp",
    "faiss/Index2Layer.cpp",
    "faiss/IndexAdditiveQuantizer.cpp",
    "faiss/IndexBinary.cpp",
    "faiss/IndexBinaryFlat.cpp",
    "faiss/IndexBinaryFromFloat.cpp",
    "faiss/IndexBinaryHNSW.cpp",
    "faiss/IndexBinaryHash.cpp",
    "faiss/IndexBinaryIVF.cpp",
    "faiss/IndexFlat.cpp",
    "faiss/IndexFlatCodes.cpp",
    "faiss/IndexHNSW.cpp",
    "faiss/IndexIDMap.cpp",
    "faiss/IndexIVF.cpp",
    "faiss/IndexIVFAdditiveQuantizer.cpp",
    "faiss/IndexIVFFlat.cpp",
    "faiss/IndexIVFPQ.cpp",
    "faiss/IndexIVFFastScan.cpp",
    "faiss/IndexIVFAdditiveQuantizerFastScan.cpp",
    "faiss/IndexIVFPQFastScan.cpp",
    "faiss/IndexIVFPQR.cpp",
    "faiss/IndexIVFSpectralHash.cpp",
    "faiss/IndexLSH.cpp",
    "faiss/IndexNNDescent.cpp",
    "faiss/IndexLattice.cpp",
    "faiss/IndexNSG.cpp",
    "faiss/IndexPQ.cpp",
    "faiss/IndexFastScan.cpp",
    "faiss/IndexAdditiveQuantizerFastScan.cpp",
    "faiss/IndexPQFastScan.cpp",
    "faiss/IndexPreTransform.cpp",
    "faiss/IndexRefine.cpp",
    "faiss/IndexReplicas.cpp",
    "faiss/IndexRowwiseMinMax.cpp",
    "faiss/IndexScalarQuantizer.cpp",
    "faiss/IndexShards.cpp",
    "faiss/MatrixStats.cpp",
    "faiss/MetaIndexes.cpp",
    "faiss/VectorTransform.cpp",
    "faiss/clone_index.cpp",
    "faiss/index_factory.cpp",

    "faiss/impl/AuxIndexStructures.cpp",
    "faiss/impl/CodePacker.cpp",
    "faiss/impl/IDSelector.cpp",
    "faiss/impl/FaissException.cpp",
    "faiss/impl/HNSW.cpp",
    "faiss/impl/NSG.cpp",
    "faiss/impl/PolysemousTraining.cpp",
    "faiss/impl/ProductQuantizer.cpp",
    "faiss/impl/AdditiveQuantizer.cpp",
    "faiss/impl/ResidualQuantizer.cpp",
    "faiss/impl/LocalSearchQuantizer.cpp",
    "faiss/impl/ProductAdditiveQuantizer.cpp",
    "faiss/impl/ScalarQuantizer.cpp",
    "faiss/impl/index_read.cpp",
    "faiss/impl/index_write.cpp",
    "faiss/impl/io.cpp",
    "faiss/impl/kmeans1d.cpp",
    "faiss/impl/lattice_Zn.cpp",
    "faiss/impl/pq4_fast_scan.cpp",
    "faiss/impl/pq4_fast_scan_search_1.cpp",
    "faiss/impl/pq4_fast_scan_search_qbs.cpp",
    "faiss/impl/NNDescent.cpp",

    "faiss/invlists/BlockInvertedLists.cpp",
    "faiss/invlists/DirectMap.cpp",
    "faiss/invlists/InvertedLists.cpp",
    "faiss/invlists/InvertedListsIOHook.cpp",

    "faiss/utils/Heap.cpp",
    "faiss/utils/WorkerThread.cpp",
    "faiss/utils/distances.cpp",
    "faiss/utils/distances_simd.cpp",
    "faiss/utils/extra_distances.cpp",
    "faiss/utils/hamming.cpp",
    "faiss/utils/partitioning.cpp",
    "faiss/utils/quantize_lut.cpp",
    "faiss/utils/random.cpp",
    "faiss/utils/sorting.cpp",
    "faiss/utils/utils.cpp",
    "faiss/utils/distances_fused/avx512.cpp",
    "faiss/utils/distances_fused/distances_fused.cpp",
    "faiss/utils/distances_fused/simdlib_based.cpp",
};
