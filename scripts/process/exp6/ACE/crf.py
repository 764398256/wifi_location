from scipy.io import loadmat
import numpy as np
import pdb

from pystruct import learners
import pystruct.models as crfs
from pystruct.utils import SaveLogger


class CRF(object):
    def __init__(self, histo, edges):
        self.histo = histo
        (voxel_num, stream_num, d, nbins) = np.shape(self.histo)
        self.edges = edges
        self.n_nodes = voxel_num
        self.n_edges = len(edges)
        self.n_features = 1
        self.n_edge_features = 1
        self.rss_start = -30
        self.rss_end = 30
        self.rss_step = 0.5
        self.nbins = (self.rss_end - self.rss_start)/self.rss_step

    def rss_range(self, val):
        return np.floor(( val - self.rss_start) / (self.rss_end - self.rss_start ) * self.nbins ) 

    def generate_test_data(self, seq):
        (dim, sample_len) = np.shape(seq)
        dataX = []
        for i in xrange(sample_len):
            pass
            

        
    def generate_data(self, seq, label):
        '''
        seq: list of [dim * sample_len], which is a combination of RSS value of a single person standing at different locations
        label: list of length voxel_num*1, each element is a tuple marking the start and end point of certain location
        '''
        (voxel_num, dim, sample_len) = np.shape(seq)
        self.n_features = dim
        self.n_edge_features = dim
        dataX = [] 
        dataY = []
        subset = 10
        for i in xrange(voxel_num* subset):
            location = [1 if np.floor( i/subset ) == t else 0 for t in xrange(self.n_nodes)]
            l = np.array(location)
            dataY.append(l)
            edges = self.edges.astype('int64')
            node_feature = np.array([ 
                                        [ -np.log(self.histo[t][j][ int(location[t] == 0) ]
                                            [ self.rss_range( seq[t][j][i% subset] ) ]) 
                                        for j in xrange(dim) ]
                                        for t in xrange(self.n_nodes) 
                                    ])

            edge_feature = np.array([ 
                                        [ (1 + np.exp(-( 
                                                    self.histo[t[0] ][j][ int(location[t[0] ] == 0) ]
                                                                [self.rss_range(seq[t[0] ][j][i% subset])] 
                                                    - self.histo[t[1]][j][int(location[t[1]] == 0)]
                                                                [self.rss_range(seq[t[1]][j][i% subset])])**2
                                          ) )/2 
                                        if (location[t[0]] != location[t[1]]) else 0 
                                        for j in xrange(dim) ] 
                                        for t in self.edges
                                    ])
            dataX.append(tuple((node_feature, edges, edge_feature))) 
        pdb.set_trace()
        return dataX, dataY


    def trainer(self, trainX, trainY):
        inf_method = ('ogm', {'alg': 'fm'})
        C = 0.01
        self.model = crfs.EdgeFeatureGraphCRF(inference_method=inf_method,
                                              symmetric_edge_features = [i for i in xrange(self.n_features)],
                                              antisymmetric_edge_features = None)
        experiment_name = 'CRF_training_nslacksvm_%s_%f'%(inf_method, C)

#     self.learner = learners.NSlackSSVM(
#                self.model, verbose=2, C= C, max_iter = 100000, n_jobs = -1,
#                tol=0.0001, show_loss_every=2,
#                logger=SaveLogger(experiment_name + ".pickle", save_every=100),
#                inactive_threshold=1e-10, inactive_window=10, batch_size=100)

        
        self.learner = learners.FrankWolfeSSVM(model=self.model,verbose=3, C=.1, max_iter=1000)
        self.learner.fit(trainX, trainY)
        pdb.set_trace()

    def predict(self, testX):
        y_pred = self.learner.predict(testX)
        return y_pred
       
    def evaluate(self, y_pred, y_real):
        pass

if __name__ == '__main__':
        
    file_p = '../../../data/exp6/mat/'
    histo = loadmat(file_p + 'histo.mat')
    edges = loadmat(file_p + 'edges.mat')
    samples = loadmat(file_p + 'sample.mat')
    test = loadmat(file_p + 'M_test.mat')
    sample_label = loadmat(file_p + 'sample_label.mat')
    histo = histo['histo']
    edges = edges['edges']
    samples = samples['M']
    test_case = test['M_test']
    sample_label = sample_label['label']
    pdb.set_trace()

    crf_instance = CRF(histo, edges)
    [trainX, trainY] = crf_instance.generate_data(samples, sample_label)
    crf_instance.trainer(trainX, trainY)
    crf_instance.score(trainX, trainY)
#print crf_instance.predict(trainX)





