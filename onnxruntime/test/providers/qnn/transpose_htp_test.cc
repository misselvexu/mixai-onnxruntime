// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#if !defined(ORT_MINIMAL_BUILD)

#include <string>
#include "core/graph/graph.h"
#include "core/graph/node_attr_utils.h"

#include "test/optimizer/qdq_test_utils.h"
#include "test/providers/qnn/qnn_test_utils.h"

#include "gtest/gtest.h"

namespace onnxruntime {
namespace test {
#if defined(__aarch64__) || defined(_M_ARM64) || defined(__linux__)

// Function that builds a model with a Transpose operator.
template <typename DataType>
GetTestModelFn BuildTransposeTestCase(const TestInputDef<DataType>& input_def,
                                      const std::vector<ONNX_NAMESPACE::AttributeProto>& attrs) {
  return [input_def, attrs](ModelTestBuilder& builder) {
    NodeArg* input = MakeTestInput(builder, input_def);

    NodeArg* output = builder.MakeOutput();
    Node& test_node = builder.AddNode("Transpose", {input}, {output});

    for (const auto& attr : attrs) {
      test_node.AddAttributeProto(attr);
    }
  };
}

// Function that builds a QDQ model with a Transpose operator.
template <typename QuantType>
static GetTestQDQModelFn<QuantType> BuildQDQTransposeTestCase(const TestInputDef<float>& input_def,
                                                              const std::vector<ONNX_NAMESPACE::AttributeProto>& attrs) {
  return [input_def, attrs](ModelTestBuilder& builder, std::vector<QuantParams<QuantType>>& output_qparams) {
    NodeArg* input = MakeTestInput(builder, input_def);
    QuantParams<QuantType> input_qparams = GetTestInputQuantParams<QuantType>(input_def);
    NodeArg* input_qdq = AddQDQNodePair(builder, input, input_qparams.scale, input_qparams.zero_point);

    auto* output = builder.MakeIntermediate();
    Node& test_node = builder.AddNode("Transpose", {input_qdq}, {output});

    for (const auto& attr : attrs) {
      test_node.AddAttributeProto(attr);
    }

    AddQDQNodePairWithOutputAsGraphOutput<QuantType>(builder, output, output_qparams[0].scale, output_qparams[0].zero_point);
  };
}

/**
 * Runs an Transpose model on the QNN HTP backend. Checks the QDQ graph node assignment, and that inference
 * outputs for QNN and CPU match.
 *
 * \param input_def The data (int32_t) input's definition (shape, is_initializer, data).
 * \attrs node attributes
 * \param expected_ep_assignment How many nodes are expected to be assigned to QNN (All, Some, or None).
 */
template <typename QuantType = uint8_t>
static void RunTransposeQDQTest(const TestInputDef<float>& input_def,
                                const std::vector<ONNX_NAMESPACE::AttributeProto>& attrs,
                                ExpectedEPNodeAssignment expected_ep_assignment) {
  ProviderOptions provider_options;
  provider_options["backend_type"] = "htp";
  provider_options["offload_graph_io_quantization"] = "0";

  // Runs model with DQ-> Transpose -> Q and compares the outputs of the CPU and QNN EPs.
  TestQDQModelAccuracy(BuildTransposeTestCase<float>(input_def, attrs),
                       BuildQDQTransposeTestCase<QuantType>(input_def, attrs),
                       provider_options,
                       18,
                       expected_ep_assignment);
}

/**
 * Runs an Transpose model on the QNN HTP backend. Checks the graph node assignment, and that inference
 * outputs for QNN and CPU match.
 *
 * \param input_def The data (int32_t) input's definition (shape, is_initializer, data).
 * \attrs node attributes
 * \param expected_ep_assignment How many nodes are expected to be assigned to QNN (All, Some, or None).
 */
template <typename DataType>
static void RunTransposeNonQDQOnHTP(const TestInputDef<DataType>& input_def,
                                    const std::vector<ONNX_NAMESPACE::AttributeProto>& attrs,
                                    ExpectedEPNodeAssignment expected_ep_assignment,
                                    bool enable_fp16_precision = true) {
  ProviderOptions provider_options;
  provider_options["backend_type"] = "htp";

  if (enable_fp16_precision) {
    provider_options["enable_htp_fp16_precision"] = "1";
  } else {
    provider_options["enable_htp_fp16_precision"] = "0";
  }

  RunQnnModelTest(BuildTransposeTestCase<DataType>(input_def, attrs),
                  provider_options,
                  13,
                  expected_ep_assignment,
                  1e-5f);
}

// Check that QNN compiles DQ -> Transpose -> Q as a single unit.
TEST_F(QnnHTPBackendTests, TransposeQDQU8) {
  RunTransposeQDQTest(TestInputDef<float>({1, 3, 224, 128}, false, 0.0f, 1.0f),
                      {utils::MakeAttribute("perm", std::vector<int64_t>{0, 2, 3, 1})},
                      ExpectedEPNodeAssignment::All);
}

// Check that QNN supports Transpose with int32 data input on HTP
TEST_F(QnnHTPBackendTests, TransposeInt32OnHTP) {
  RunTransposeNonQDQOnHTP<int32_t>(TestInputDef<int32_t>({1, 3, 224, 128}, false, -100, 100),
                                   {utils::MakeAttribute("perm", std::vector<int64_t>{0, 2, 3, 1})},
                                   ExpectedEPNodeAssignment::All);
}

// Check that QNN supports Transpose with float32 data input on HTP
// Fails with QNN SDK 2.35.0:
// value pair (0.183528364, 0.183471695) at index #0 don't match, which is -5.66691e-05 from 0.183528
TEST_F(QnnHTPBackendTests, DISABLED_TransposeFloatOnHTP) {
  RunTransposeNonQDQOnHTP<float>(TestInputDef<float>({1, 3, 224, 128}, false, 0, 10.0f),
                                 {utils::MakeAttribute("perm", std::vector<int64_t>{0, 2, 3, 1})},
                                 ExpectedEPNodeAssignment::All, false);
}

#endif  // defined(__aarch64__) || defined(_M_ARM64) || defined(__linux__)

}  // namespace test
}  // namespace onnxruntime

#endif
