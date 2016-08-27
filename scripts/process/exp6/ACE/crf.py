from scipy.io import loadmat
import numpy as np
import pdb
import pickle
from pystruct import learners
import pystruct.models as crfs
from pystruct.utils import SaveLogger
import sys
import maxflow

class CRF(object):
    def __init__(self, histo, edges):
        self.histo = histo
        (voxel_num, stream_num, d, nbins) = np.shape(self.histo)
        self.edges = edges
        self.n_nodes = voxel_num
        self.n_edges = len(edges)
        self.n_features = 1
        self.n_edge_features = 1
        self.n_states = 2
        self.rss_start = -30
        self.rss_end = 30
        self.rss_step = 0.5
        self.nbins = (self.rss_end - self.rss_start)/self.rss_step

    def rss_range(self, val):
        return np.floor(( val - self.rss_start) / (self.rss_end - self.rss_start ) * self.nbins ) 

    def map_estimate(self, seq):
        (dim, sample_len) = np.shape(seq)
        dataX = []
        w = np.ones(np.shape(self.learner.w))

        import pdb
        pdb.set_trace()
        edge_dict = {}
        max_iter = 100
        for i, edge in enumerate(self.edges):
            if edge[0] not in edge_dict.keys():
               edge_dict[ edge[0] ] = [(i, edge)]
            else:
               edge_dict[ edge[0] ] = edge_dict[ edge[0] ] + [(i, edge)]
                   
        for i in xrange(sample_len):
            labels = np.array([ int(np.random.random()*self.n_states) for i in xrange(self.n_nodes)]) 
            # build matrix D
            D = np.array([ [ 
                            [-np.log(self.histo[t][j][k][ self.rss_range( seq[j][i] ) ]) for k in xrange(self.n_states) ]
                            for j in xrange(dim)]  
                            for t in xrange(self.n_nodes) ])
            D *= 1
            # build matrix v
            v = np.array([[ [ [  (1 + np.exp(-( 
                                                    self.histo[t[0]][j][k]
                                                                [self.rss_range(seq[j][i])] 
                                                    - self.histo[t[1]][j][l]
                                                                [self.rss_range(seq[j][i])])**2
                                          ) )/2 
                        for l in xrange(self.n_states)] 
                        for k in xrange(self.n_states) ]
                        for j in xrange(dim)]
                        for t in self.edges])
            v *= 1
            pdb.set_trace()
            labels = self.cv_alpha_extension(D, w, max_iter, edge_dict, v, labels)
            print labels
            pdb.set_trace()

    def cv_alpha_extension(self, D, w, max_iter, edge_dict, v, labels):
        '''
            D: unary cost for each label for different nodes, shape of (num_nodes,num_features, num_labels)
            edge_dict { key:id of first_node, value: (id in edge feature array 'v', list of edges starting with first_node) }
            v: edge feature array, shape of (id, features, n_states, n_states )
            '''
        assert labels.shape[0] == D.shape[0]
        assert D.shape[2] == self.n_states

        n_nodes = labels.shape[0] 
        n_features = D.shape[1]
        n_edge_features = v.shape[1]
        success = 0
        best_energy = sys.maxint
        w_offset = self.n_states* n_features
        for it in xrange(max_iter):
#print 'Iteration %d'%it
            # Process the neighbors
            for alpha in xrange(self.n_states):
#               print 'alpha: %d'%alpha
                # create the graph
                g = maxflow.GraphFloat()
                g.add_nodes(n_nodes)

                for node_index in xrange(n_nodes):
#                   print "node: ", node_index
                    label = labels[node_index]
                    # TBD
                    t1 = sum([ w[i + alpha* n_features] * D[node_index][i] [alpha] for i in xrange(n_features) ])
                    t2 = sys.maxint
                    if label != alpha:
                        t2 = sum([ w[i + label* n_features] * D[node_index][i] [label] for i in xrange(n_features) ])               
#print t1, t2
                    g.add_tedge(node_index, t1, t2)
#                   print t1, t2                 
                    if node_index not in edge_dict.keys():
                        continue
                        
                    for (_id, edge) in edge_dict[node_index]:
#                       print "Edge: ", edge
                        assert edge[0] == node_index
                        nnode_index = edge[1]
                        nlabel = labels[nnode_index]
                        nnstates = self.n_states ** 2 
                        dist_label_alpha = sum([ np.mean([w[ w_offset + i*nnstates + label * self.n_states + alpha ]*v[_id][i][label][alpha],w[ w_offset + i*nnstates + alpha * self.n_states + label ]*v[_id][i][alpha][label]])  for i in xrange(n_edge_features)])
#                       print label, nlabel 

                        if label == nlabel:
#                           print "connect two node with weight: %f"%dist_label_alpha
                            g.add_edge(node_index, nnode_index, dist_label_alpha, dist_label_alpha)
                            continue
                        # if labelk are different , add an extra node
                        dist_nlabel_alpha = sum([ np.mean([w[w_offset + i*nnstates + self.n_states* nlabel + alpha]*v[_id][i][nlabel][alpha],w[ w_offset + i* nnstates + self.n_states* alpha + nlabel]*v[_id][i][alpha][nlabel]])  for i in xrange(n_edge_features)])
                        dist_label_nlabel = sum([ np.mean([w[w_offset + i*nnstates + self.n_states*nlabel + label]*v[_id][i][nlabel][label],w[w_offset + i*nnstates + self.n_states* label + nlabel]*v[_id][i][label][nlabel]])  for i in xrange(n_edge_features)])
                        extra_node = g.add_nodes(1)
                        g.add_tedge(extra_node, 0, dist_label_nlabel)
                        g.add_edge(node_index, extra_node, dist_label_alpha, dist_label_alpha )
                        g.add_edge(nnode_index, extra_node, dist_nlabel_alpha, dist_nlabel_alpha )
#                       print "add a new node, with tweight %f, weight to two end notes(%f, %f)"%(dist_label_nlabel, dist_label_alpha, dist_nlabel_alpha)

                pdb.set_trace()
                energy = g.maxflow()
                for node_index in xrange(n_nodes):
                    if g.get_segment(node_index) == 1: # SINK = 1, SOUCE = 0
                        labels[node_index] = alpha

                print energy, labels 
                if energy < best_energy:
                    success = 1
                    best_energy = energy
                    print "Energy of the last cut (alpha = %r): %r"%(alpha, energy)

                if not success:
                    print 'failed!'
                    break
        return labels

               

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
#inf_method = 'lp'
        C = 1
        self.model = crfs.EdgeFeatureGraphCRF(inference_method=inf_method,
                                              symmetric_edge_features = [i for i in xrange(self.n_features)],
                                              antisymmetric_edge_features = None)
        experiment_name = 'CRF_training_nslacksvm_%s_%f'%(inf_method, C)

#     self.learner = learners.NSlackSSVM(
#                self.model, verbose=2, C= C, max_iter = 100000, n_jobs = -1,
#                tol=0.0001, show_loss_every=2,
#                logger=SaveLogger(experiment_name + ".pickle", save_every=100),
#                inactive_threshold=1e-10, inactive_window=10, batch_size=100)

        
#self.learner = learners.FrankWolfeSSVM(model=self.model,verbose=3, C=C, max_iter=100)
        self.learner = learners.SubgradientSSVMMOD(model=self.model,verbose=3, C=C, max_iter=10, show_loss_every=1)
        self.learner.fit(trainX, trainY)

    def predict(self, testX, validates):
        if validates:
            y_pred = self.learner.predict(testX)
        else:
            y_pred = self.map_estimate(testX)
        return y_pred
       
    def evaluate(self, y_pred, y_real):
        pass

def pickle_save(fname, data):
    with open(fname, 'wb') as output:
        pickle.dump(data, output, pickle.HIGHEST_PROTOCOL)
        print "saved to %s"%fname

def pickle_load(fname):
    with open(fname, 'rb') as _input:
        return pickle.load(_input)
        
if __name__ == '__main__':
        
    file_p = '../../../data/exp6/mat/'
    histo = loadmat(file_p + 'histo.mat')
    edges = loadmat(file_p + 'edges.mat')
    samples = loadmat(file_p + 'sample.mat')
    #test = loadmat(file_p + 'M_test_fg_three_13_17_112.mat')
    test = loadmat(file_p + 'M_test_fg_three_13_17_112.mat')
    sample_label = loadmat(file_p + 'sample_label.mat')
    histo = histo['histo']
    edges = edges['edges']
    samples = samples['M']
    test_case = test['M_test']
    sample_label = sample_label['label']
    train_flag = 0
    
    model_file = 'model.pkl'
    if train_flag:
        crf_instance = CRF(histo, edges)
        [trainX, trainY] = crf_instance.generate_data(samples, sample_label)
        crf_instance.trainer(trainX, trainY)
        pickle_save(model_file,crf_instance)
        print crf_instance.learner.score(trainX, trainY), crf_instance.predict(trainX[0:2], True)
        pdb.set_trace()

    else:
        crf_instance = pickle_load(model_file)

    [trainX, trainY] = crf_instance.generate_data(samples, sample_label)
    print crf_instance.predict(trainX[0:2], True)
    pdb.set_trace()
    print crf_instance.predict(samples[0], False) 
#labels = crf_instance.predict(test_case, 1)
#crf_instance.score(trainX, trainY)
#print crf_instance.predict(trainX)





