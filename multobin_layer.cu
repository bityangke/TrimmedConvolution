#include <vector>
#include "caffe/blob.hpp"
#include "caffe/common.hpp"
#include "caffe/filler.hpp"
#include "caffe/layer.hpp"
#include "caffe/util/math_functions.hpp"
#include "multobin_layer.hpp"
namespace caffe {
	template <typename Dtype>
	__global__ void multobin_forward_gpu_kernel(const int nthreads, const Dtype * const bottom, Dtype * const top,
		const int inner_size, const int channel, const int level) {
		CUDA_KERNEL_LOOP(index, nthreads) {
			int ts = index % inner_size;
			int tc = (index / inner_size) % channel;
			int tn = (index / inner_size / channel);
			int pbase = tn*channel*level*inner_size + tc*level*inner_size + ts;
			unsigned int data = static_cast <int>(bottom[index]);
			for (int j = 0; j < level; j++)
			{
				top[pbase] = data % 2;
				data = data >> 1;
				pbase += inner_size;
			}
		}
	}
	template <typename Dtype>
	void MulToBinLayer<Dtype>::Forward_gpu(const vector<Blob<Dtype>*>& bottom,
		const vector<Blob<Dtype>*>& top) {
		const Dtype* bottom_data = bottom[0]->gpu_data();
		int num = bottom[0]->count();
		multobin_forward_gpu_kernel<Dtype> << <CAFFE_GET_BLOCKS(num), CAFFE_CUDA_NUM_THREADS >> >
			(num, bottom_data,top[0]->mutable_gpu_data(), inner_size_, channel_, levels_);
		CUDA_POST_KERNEL_CHECK;
	}

	template <typename Dtype>
	void MulToBinLayer<Dtype>::Backward_gpu(const vector<Blob<Dtype>*>& top,
		const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {
		
	}

	INSTANTIATE_LAYER_GPU_FUNCS(MulToBinLayer);

}  // namespace caffe
