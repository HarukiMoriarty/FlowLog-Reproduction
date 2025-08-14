#define SOUFFLE_GENERATOR_VERSION "2.4"
#include "souffle/CompiledSouffle.h"
#include "souffle/SignalHandler.h"
#include "souffle/SouffleInterface.h"
#include "souffle/datastructure/BTree.h"
#include "souffle/io/IOSystem.h"
#include <any>
namespace functors {
extern "C" {
}
} //namespace functors
namespace souffle::t_btree_ii__0_1__11 {
using namespace souffle;
struct Type {
static constexpr Relation::arity_type Arity = 2;
using t_tuple = Tuple<RamDomain, 2>;
struct t_comparator_0{
 int operator()(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0])) ? -1 : (ramBitCast<RamSigned>(a[0]) > ramBitCast<RamSigned>(b[0])) ? 1 :((ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1])) ? -1 : (ramBitCast<RamSigned>(a[1]) > ramBitCast<RamSigned>(b[1])) ? 1 :(0));
 }
bool less(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0]))|| ((ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0])) && ((ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1]))));
 }
bool equal(const t_tuple& a, const t_tuple& b) const {
return (ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0]))&&(ramBitCast<RamSigned>(a[1]) == ramBitCast<RamSigned>(b[1]));
 }
};
using t_ind_0 = btree_set<t_tuple,t_comparator_0>;
t_ind_0 ind_0;
using iterator = t_ind_0::iterator;
struct context {
t_ind_0::operation_hints hints_0_lower;
t_ind_0::operation_hints hints_0_upper;
};
context createContext() { return context(); }
bool insert(const t_tuple& t);
bool insert(const t_tuple& t, context& h);
bool insert(const RamDomain* ramDomain);
bool insert(RamDomain a0,RamDomain a1);
bool contains(const t_tuple& t, context& h) const;
bool contains(const t_tuple& t) const;
std::size_t size() const;
iterator find(const t_tuple& t, context& h) const;
iterator find(const t_tuple& t) const;
range<iterator> lowerUpperRange_00(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const;
range<iterator> lowerUpperRange_00(const t_tuple& /* lower */, const t_tuple& /* upper */) const;
range<t_ind_0::iterator> lowerUpperRange_11(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_0::iterator> lowerUpperRange_11(const t_tuple& lower, const t_tuple& upper) const;
bool empty() const;
std::vector<range<iterator>> partition() const;
void purge();
iterator begin() const;
iterator end() const;
void printStatistics(std::ostream& o) const;
};
} // namespace souffle::t_btree_ii__0_1__11 
namespace souffle::t_btree_ii__0_1__11 {
using namespace souffle;
using t_ind_0 = Type::t_ind_0;
using iterator = Type::iterator;
using context = Type::context;
bool Type::insert(const t_tuple& t) {
context h;
return insert(t, h);
}
bool Type::insert(const t_tuple& t, context& h) {
if (ind_0.insert(t, h.hints_0_lower)) {
return true;
} else return false;
}
bool Type::insert(const RamDomain* ramDomain) {
RamDomain data[2];
std::copy(ramDomain, ramDomain + 2, data);
const t_tuple& tuple = reinterpret_cast<const t_tuple&>(data);
context h;
return insert(tuple, h);
}
bool Type::insert(RamDomain a0,RamDomain a1) {
RamDomain data[2] = {a0,a1};
return insert(data);
}
bool Type::contains(const t_tuple& t, context& h) const {
return ind_0.contains(t, h.hints_0_lower);
}
bool Type::contains(const t_tuple& t) const {
context h;
return contains(t, h);
}
std::size_t Type::size() const {
return ind_0.size();
}
iterator Type::find(const t_tuple& t, context& h) const {
return ind_0.find(t, h.hints_0_lower);
}
iterator Type::find(const t_tuple& t) const {
context h;
return find(t, h);
}
range<iterator> Type::lowerUpperRange_00(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<iterator> Type::lowerUpperRange_00(const t_tuple& /* lower */, const t_tuple& /* upper */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<t_ind_0::iterator> Type::lowerUpperRange_11(const t_tuple& lower, const t_tuple& upper, context& h) const {
t_comparator_0 comparator;
int cmp = comparator(lower, upper);
if (cmp == 0) {
    auto pos = ind_0.find(lower, h.hints_0_lower);
    auto fin = ind_0.end();
    if (pos != fin) {fin = pos; ++fin;}
    return make_range(pos, fin);
}
if (cmp > 0) {
    return make_range(ind_0.end(), ind_0.end());
}
return make_range(ind_0.lower_bound(lower, h.hints_0_lower), ind_0.upper_bound(upper, h.hints_0_upper));
}
range<t_ind_0::iterator> Type::lowerUpperRange_11(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_11(lower,upper,h);
}
bool Type::empty() const {
return ind_0.empty();
}
std::vector<range<iterator>> Type::partition() const {
return ind_0.getChunks(400);
}
void Type::purge() {
ind_0.clear();
}
iterator Type::begin() const {
return ind_0.begin();
}
iterator Type::end() const {
return ind_0.end();
}
void Type::printStatistics(std::ostream& o) const {
o << " arity 2 direct b-tree index 0 lex-order [0,1]\n";
ind_0.printStats(o);
}
} // namespace souffle::t_btree_ii__0_1__11 
namespace souffle::t_btree_i__0__1 {
using namespace souffle;
struct Type {
static constexpr Relation::arity_type Arity = 1;
using t_tuple = Tuple<RamDomain, 1>;
struct t_comparator_0{
 int operator()(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0])) ? -1 : (ramBitCast<RamSigned>(a[0]) > ramBitCast<RamSigned>(b[0])) ? 1 :(0);
 }
bool less(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0]));
 }
bool equal(const t_tuple& a, const t_tuple& b) const {
return (ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0]));
 }
};
using t_ind_0 = btree_set<t_tuple,t_comparator_0>;
t_ind_0 ind_0;
using iterator = t_ind_0::iterator;
struct context {
t_ind_0::operation_hints hints_0_lower;
t_ind_0::operation_hints hints_0_upper;
};
context createContext() { return context(); }
bool insert(const t_tuple& t);
bool insert(const t_tuple& t, context& h);
bool insert(const RamDomain* ramDomain);
bool insert(RamDomain a0);
bool contains(const t_tuple& t, context& h) const;
bool contains(const t_tuple& t) const;
std::size_t size() const;
iterator find(const t_tuple& t, context& h) const;
iterator find(const t_tuple& t) const;
range<iterator> lowerUpperRange_0(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const;
range<iterator> lowerUpperRange_0(const t_tuple& /* lower */, const t_tuple& /* upper */) const;
range<t_ind_0::iterator> lowerUpperRange_1(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_0::iterator> lowerUpperRange_1(const t_tuple& lower, const t_tuple& upper) const;
bool empty() const;
std::vector<range<iterator>> partition() const;
void purge();
iterator begin() const;
iterator end() const;
void printStatistics(std::ostream& o) const;
};
} // namespace souffle::t_btree_i__0__1 
namespace souffle::t_btree_i__0__1 {
using namespace souffle;
using t_ind_0 = Type::t_ind_0;
using iterator = Type::iterator;
using context = Type::context;
bool Type::insert(const t_tuple& t) {
context h;
return insert(t, h);
}
bool Type::insert(const t_tuple& t, context& h) {
if (ind_0.insert(t, h.hints_0_lower)) {
return true;
} else return false;
}
bool Type::insert(const RamDomain* ramDomain) {
RamDomain data[1];
std::copy(ramDomain, ramDomain + 1, data);
const t_tuple& tuple = reinterpret_cast<const t_tuple&>(data);
context h;
return insert(tuple, h);
}
bool Type::insert(RamDomain a0) {
RamDomain data[1] = {a0};
return insert(data);
}
bool Type::contains(const t_tuple& t, context& h) const {
return ind_0.contains(t, h.hints_0_lower);
}
bool Type::contains(const t_tuple& t) const {
context h;
return contains(t, h);
}
std::size_t Type::size() const {
return ind_0.size();
}
iterator Type::find(const t_tuple& t, context& h) const {
return ind_0.find(t, h.hints_0_lower);
}
iterator Type::find(const t_tuple& t) const {
context h;
return find(t, h);
}
range<iterator> Type::lowerUpperRange_0(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<iterator> Type::lowerUpperRange_0(const t_tuple& /* lower */, const t_tuple& /* upper */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<t_ind_0::iterator> Type::lowerUpperRange_1(const t_tuple& lower, const t_tuple& upper, context& h) const {
t_comparator_0 comparator;
int cmp = comparator(lower, upper);
if (cmp == 0) {
    auto pos = ind_0.find(lower, h.hints_0_lower);
    auto fin = ind_0.end();
    if (pos != fin) {fin = pos; ++fin;}
    return make_range(pos, fin);
}
if (cmp > 0) {
    return make_range(ind_0.end(), ind_0.end());
}
return make_range(ind_0.lower_bound(lower, h.hints_0_lower), ind_0.upper_bound(upper, h.hints_0_upper));
}
range<t_ind_0::iterator> Type::lowerUpperRange_1(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_1(lower,upper,h);
}
bool Type::empty() const {
return ind_0.empty();
}
std::vector<range<iterator>> Type::partition() const {
return ind_0.getChunks(400);
}
void Type::purge() {
ind_0.clear();
}
iterator Type::begin() const {
return ind_0.begin();
}
iterator Type::end() const {
return ind_0.end();
}
void Type::printStatistics(std::ostream& o) const {
o << " arity 1 direct b-tree index 0 lex-order [0]\n";
ind_0.printStats(o);
}
} // namespace souffle::t_btree_i__0__1 
namespace  souffle {
using namespace souffle;
class Stratum_Arc_52d74c4c48628683 {
public:
 Stratum_Arc_52d74c4c48628683(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_Arc_b47d9f303bde53a1);
void run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret);
private:
SymbolTable& symTable;
RecordTable& recordTable;
ConcurrentCache<std::string,std::regex>& regexCache;
bool& pruneImdtRels;
bool& performIO;
SignalHandler*& signalHandler;
std::atomic<std::size_t>& iter;
std::atomic<RamDomain>& ctr;
std::string& inputDirectory;
std::string& outputDirectory;
t_btree_ii__0_1__11::Type* rel_Arc_b47d9f303bde53a1;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_Arc_52d74c4c48628683::Stratum_Arc_52d74c4c48628683(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_Arc_b47d9f303bde53a1):
symTable(symTable),
recordTable(recordTable),
regexCache(regexCache),
pruneImdtRels(pruneImdtRels),
performIO(performIO),
signalHandler(signalHandler),
iter(iter),
ctr(ctr),
inputDirectory(inputDirectory),
outputDirectory(outputDirectory),
rel_Arc_b47d9f303bde53a1(&rel_Arc_b47d9f303bde53a1){
}

void Stratum_Arc_52d74c4c48628683::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","y,x"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Arc.csv"},{"name","Arc"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"y\", \"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Arc_b47d9f303bde53a1);
} catch (std::exception& e) {std::cerr << "Error loading Arc data: " << e.what() << '\n';
exit(1);
}
}
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_BipartiteViolation_40f1ed098f44af96 {
public:
 Stratum_BipartiteViolation_40f1ed098f44af96(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_i__0__1::Type& rel_BipartiteViolation_a439a62602a351d9,t_btree_i__0__1::Type& rel_One_4507392ecc2d4a7d,t_btree_i__0__1::Type& rel_Zero_802d75c8c4d7ef88);
void run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret);
private:
SymbolTable& symTable;
RecordTable& recordTable;
ConcurrentCache<std::string,std::regex>& regexCache;
bool& pruneImdtRels;
bool& performIO;
SignalHandler*& signalHandler;
std::atomic<std::size_t>& iter;
std::atomic<RamDomain>& ctr;
std::string& inputDirectory;
std::string& outputDirectory;
t_btree_i__0__1::Type* rel_BipartiteViolation_a439a62602a351d9;
t_btree_i__0__1::Type* rel_One_4507392ecc2d4a7d;
t_btree_i__0__1::Type* rel_Zero_802d75c8c4d7ef88;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_BipartiteViolation_40f1ed098f44af96::Stratum_BipartiteViolation_40f1ed098f44af96(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_i__0__1::Type& rel_BipartiteViolation_a439a62602a351d9,t_btree_i__0__1::Type& rel_One_4507392ecc2d4a7d,t_btree_i__0__1::Type& rel_Zero_802d75c8c4d7ef88):
symTable(symTable),
recordTable(recordTable),
regexCache(regexCache),
pruneImdtRels(pruneImdtRels),
performIO(performIO),
signalHandler(signalHandler),
iter(iter),
ctr(ctr),
inputDirectory(inputDirectory),
outputDirectory(outputDirectory),
rel_BipartiteViolation_a439a62602a351d9(&rel_BipartiteViolation_a439a62602a351d9),
rel_One_4507392ecc2d4a7d(&rel_One_4507392ecc2d4a7d),
rel_Zero_802d75c8c4d7ef88(&rel_Zero_802d75c8c4d7ef88){
}

void Stratum_BipartiteViolation_40f1ed098f44af96::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
signalHandler->setMsg(R"_(BipartiteViolation(x) :- 
   One(x),
   Zero(x).
in file bipartite.dl [19:1-19:42])_");
if(!(rel_One_4507392ecc2d4a7d->empty()) && !(rel_Zero_802d75c8c4d7ef88->empty())) {
[&](){
auto part = rel_One_4507392ecc2d4a7d->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_BipartiteViolation_a439a62602a351d9_op_ctxt,rel_BipartiteViolation_a439a62602a351d9->createContext());
CREATE_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt,rel_One_4507392ecc2d4a7d->createContext());
CREATE_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt,rel_Zero_802d75c8c4d7ef88->createContext());

                   #if defined _OPENMP && _OPENMP < 200805
                           auto count = std::distance(part.begin(), part.end());
                           auto base = part.begin();
                           pfor(int index  = 0; index < count; index++) {
                               auto it = base + index;
                   #else
                           pfor(auto it = part.begin(); it < part.end(); it++) {
                   #endif
                   try{
for(const auto& env0 : *it) {
if( rel_Zero_802d75c8c4d7ef88->contains(Tuple<RamDomain,1>{{ramBitCast(env0[0])}},READ_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt))) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_BipartiteViolation_a439a62602a351d9->insert(tuple,READ_OP_CONTEXT(rel_BipartiteViolation_a439a62602a351d9_op_ctxt));
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x"},{"auxArity","0"},{"name","BipartiteViolation"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (outputDirectory == "-"){directiveMap["IO"] = "stdout"; directiveMap["headers"] = "true";}
else if (!outputDirectory.empty()) {directiveMap["output-dir"] = outputDirectory;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_BipartiteViolation_a439a62602a351d9);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_One_08d574766b0cbe45 {
public:
 Stratum_One_08d574766b0cbe45(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_i__0__1::Type& rel_delta_One_cb75c6228d9f24de,t_btree_i__0__1::Type& rel_delta_Zero_6b6447da41da1e01,t_btree_i__0__1::Type& rel_new_One_4ca429d50d22d3c9,t_btree_i__0__1::Type& rel_new_Zero_ce0b69b0f9af6cbb,t_btree_ii__0_1__11::Type& rel_Arc_b47d9f303bde53a1,t_btree_i__0__1::Type& rel_One_4507392ecc2d4a7d,t_btree_i__0__1::Type& rel_Source_724b8cde435eac4d,t_btree_i__0__1::Type& rel_Zero_802d75c8c4d7ef88);
void run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret);
private:
SymbolTable& symTable;
RecordTable& recordTable;
ConcurrentCache<std::string,std::regex>& regexCache;
bool& pruneImdtRels;
bool& performIO;
SignalHandler*& signalHandler;
std::atomic<std::size_t>& iter;
std::atomic<RamDomain>& ctr;
std::string& inputDirectory;
std::string& outputDirectory;
t_btree_i__0__1::Type* rel_delta_One_cb75c6228d9f24de;
t_btree_i__0__1::Type* rel_delta_Zero_6b6447da41da1e01;
t_btree_i__0__1::Type* rel_new_One_4ca429d50d22d3c9;
t_btree_i__0__1::Type* rel_new_Zero_ce0b69b0f9af6cbb;
t_btree_ii__0_1__11::Type* rel_Arc_b47d9f303bde53a1;
t_btree_i__0__1::Type* rel_One_4507392ecc2d4a7d;
t_btree_i__0__1::Type* rel_Source_724b8cde435eac4d;
t_btree_i__0__1::Type* rel_Zero_802d75c8c4d7ef88;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_One_08d574766b0cbe45::Stratum_One_08d574766b0cbe45(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_i__0__1::Type& rel_delta_One_cb75c6228d9f24de,t_btree_i__0__1::Type& rel_delta_Zero_6b6447da41da1e01,t_btree_i__0__1::Type& rel_new_One_4ca429d50d22d3c9,t_btree_i__0__1::Type& rel_new_Zero_ce0b69b0f9af6cbb,t_btree_ii__0_1__11::Type& rel_Arc_b47d9f303bde53a1,t_btree_i__0__1::Type& rel_One_4507392ecc2d4a7d,t_btree_i__0__1::Type& rel_Source_724b8cde435eac4d,t_btree_i__0__1::Type& rel_Zero_802d75c8c4d7ef88):
symTable(symTable),
recordTable(recordTable),
regexCache(regexCache),
pruneImdtRels(pruneImdtRels),
performIO(performIO),
signalHandler(signalHandler),
iter(iter),
ctr(ctr),
inputDirectory(inputDirectory),
outputDirectory(outputDirectory),
rel_delta_One_cb75c6228d9f24de(&rel_delta_One_cb75c6228d9f24de),
rel_delta_Zero_6b6447da41da1e01(&rel_delta_Zero_6b6447da41da1e01),
rel_new_One_4ca429d50d22d3c9(&rel_new_One_4ca429d50d22d3c9),
rel_new_Zero_ce0b69b0f9af6cbb(&rel_new_Zero_ce0b69b0f9af6cbb),
rel_Arc_b47d9f303bde53a1(&rel_Arc_b47d9f303bde53a1),
rel_One_4507392ecc2d4a7d(&rel_One_4507392ecc2d4a7d),
rel_Source_724b8cde435eac4d(&rel_Source_724b8cde435eac4d),
rel_Zero_802d75c8c4d7ef88(&rel_Zero_802d75c8c4d7ef88){
}

void Stratum_One_08d574766b0cbe45::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
signalHandler->setMsg(R"_(Zero(x) :- 
   Source(x).
in file bipartite.dl [11:1-11:22])_");
if(!(rel_Source_724b8cde435eac4d->empty())) {
[&](){
CREATE_OP_CONTEXT(rel_Source_724b8cde435eac4d_op_ctxt,rel_Source_724b8cde435eac4d->createContext());
CREATE_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt,rel_Zero_802d75c8c4d7ef88->createContext());
for(const auto& env0 : *rel_Source_724b8cde435eac4d) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_Zero_802d75c8c4d7ef88->insert(tuple,READ_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt));
}
}
();}
[&](){
CREATE_OP_CONTEXT(rel_delta_One_cb75c6228d9f24de_op_ctxt,rel_delta_One_cb75c6228d9f24de->createContext());
CREATE_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt,rel_One_4507392ecc2d4a7d->createContext());
for(const auto& env0 : *rel_One_4507392ecc2d4a7d) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_delta_One_cb75c6228d9f24de->insert(tuple,READ_OP_CONTEXT(rel_delta_One_cb75c6228d9f24de_op_ctxt));
}
}
();[&](){
CREATE_OP_CONTEXT(rel_delta_Zero_6b6447da41da1e01_op_ctxt,rel_delta_Zero_6b6447da41da1e01->createContext());
CREATE_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt,rel_Zero_802d75c8c4d7ef88->createContext());
for(const auto& env0 : *rel_Zero_802d75c8c4d7ef88) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_delta_Zero_6b6447da41da1e01->insert(tuple,READ_OP_CONTEXT(rel_delta_Zero_6b6447da41da1e01_op_ctxt));
}
}
();iter = 0;
for(;;) {
signalHandler->setMsg(R"_(One(y) :- 
   Arc(x,y),
   Zero(x).
in file bipartite.dl [13:1-13:30])_");
if(!(rel_Arc_b47d9f303bde53a1->empty()) && !(rel_delta_Zero_6b6447da41da1e01->empty())) {
[&](){
auto part = rel_Arc_b47d9f303bde53a1->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_Zero_6b6447da41da1e01_op_ctxt,rel_delta_Zero_6b6447da41da1e01->createContext());
CREATE_OP_CONTEXT(rel_new_One_4ca429d50d22d3c9_op_ctxt,rel_new_One_4ca429d50d22d3c9->createContext());
CREATE_OP_CONTEXT(rel_Arc_b47d9f303bde53a1_op_ctxt,rel_Arc_b47d9f303bde53a1->createContext());
CREATE_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt,rel_One_4507392ecc2d4a7d->createContext());

                   #if defined _OPENMP && _OPENMP < 200805
                           auto count = std::distance(part.begin(), part.end());
                           auto base = part.begin();
                           pfor(int index  = 0; index < count; index++) {
                               auto it = base + index;
                   #else
                           pfor(auto it = part.begin(); it < part.end(); it++) {
                   #endif
                   try{
for(const auto& env0 : *it) {
if( rel_delta_Zero_6b6447da41da1e01->contains(Tuple<RamDomain,1>{{ramBitCast(env0[0])}},READ_OP_CONTEXT(rel_delta_Zero_6b6447da41da1e01_op_ctxt)) && !(rel_One_4507392ecc2d4a7d->contains(Tuple<RamDomain,1>{{ramBitCast(env0[1])}},READ_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt)))) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[1])}};
rel_new_One_4ca429d50d22d3c9->insert(tuple,READ_OP_CONTEXT(rel_new_One_4ca429d50d22d3c9_op_ctxt));
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
signalHandler->setMsg(R"_(One(x) :- 
   Arc(x,y),
   Zero(y).
in file bipartite.dl [14:1-14:30])_");
if(!(rel_Arc_b47d9f303bde53a1->empty()) && !(rel_delta_Zero_6b6447da41da1e01->empty())) {
[&](){
auto part = rel_Arc_b47d9f303bde53a1->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_Zero_6b6447da41da1e01_op_ctxt,rel_delta_Zero_6b6447da41da1e01->createContext());
CREATE_OP_CONTEXT(rel_new_One_4ca429d50d22d3c9_op_ctxt,rel_new_One_4ca429d50d22d3c9->createContext());
CREATE_OP_CONTEXT(rel_Arc_b47d9f303bde53a1_op_ctxt,rel_Arc_b47d9f303bde53a1->createContext());
CREATE_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt,rel_One_4507392ecc2d4a7d->createContext());

                   #if defined _OPENMP && _OPENMP < 200805
                           auto count = std::distance(part.begin(), part.end());
                           auto base = part.begin();
                           pfor(int index  = 0; index < count; index++) {
                               auto it = base + index;
                   #else
                           pfor(auto it = part.begin(); it < part.end(); it++) {
                   #endif
                   try{
for(const auto& env0 : *it) {
if( rel_delta_Zero_6b6447da41da1e01->contains(Tuple<RamDomain,1>{{ramBitCast(env0[1])}},READ_OP_CONTEXT(rel_delta_Zero_6b6447da41da1e01_op_ctxt)) && !(rel_One_4507392ecc2d4a7d->contains(Tuple<RamDomain,1>{{ramBitCast(env0[0])}},READ_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt)))) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_new_One_4ca429d50d22d3c9->insert(tuple,READ_OP_CONTEXT(rel_new_One_4ca429d50d22d3c9_op_ctxt));
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
signalHandler->setMsg(R"_(Zero(y) :- 
   Arc(x,y),
   One(x).
in file bipartite.dl [16:1-16:30])_");
if(!(rel_Arc_b47d9f303bde53a1->empty()) && !(rel_delta_One_cb75c6228d9f24de->empty())) {
[&](){
auto part = rel_Arc_b47d9f303bde53a1->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_One_cb75c6228d9f24de_op_ctxt,rel_delta_One_cb75c6228d9f24de->createContext());
CREATE_OP_CONTEXT(rel_new_Zero_ce0b69b0f9af6cbb_op_ctxt,rel_new_Zero_ce0b69b0f9af6cbb->createContext());
CREATE_OP_CONTEXT(rel_Arc_b47d9f303bde53a1_op_ctxt,rel_Arc_b47d9f303bde53a1->createContext());
CREATE_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt,rel_Zero_802d75c8c4d7ef88->createContext());

                   #if defined _OPENMP && _OPENMP < 200805
                           auto count = std::distance(part.begin(), part.end());
                           auto base = part.begin();
                           pfor(int index  = 0; index < count; index++) {
                               auto it = base + index;
                   #else
                           pfor(auto it = part.begin(); it < part.end(); it++) {
                   #endif
                   try{
for(const auto& env0 : *it) {
if( rel_delta_One_cb75c6228d9f24de->contains(Tuple<RamDomain,1>{{ramBitCast(env0[0])}},READ_OP_CONTEXT(rel_delta_One_cb75c6228d9f24de_op_ctxt)) && !(rel_Zero_802d75c8c4d7ef88->contains(Tuple<RamDomain,1>{{ramBitCast(env0[1])}},READ_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt)))) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[1])}};
rel_new_Zero_ce0b69b0f9af6cbb->insert(tuple,READ_OP_CONTEXT(rel_new_Zero_ce0b69b0f9af6cbb_op_ctxt));
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
signalHandler->setMsg(R"_(Zero(x) :- 
   Arc(x,y),
   One(y).
in file bipartite.dl [17:1-17:30])_");
if(!(rel_Arc_b47d9f303bde53a1->empty()) && !(rel_delta_One_cb75c6228d9f24de->empty())) {
[&](){
auto part = rel_Arc_b47d9f303bde53a1->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_One_cb75c6228d9f24de_op_ctxt,rel_delta_One_cb75c6228d9f24de->createContext());
CREATE_OP_CONTEXT(rel_new_Zero_ce0b69b0f9af6cbb_op_ctxt,rel_new_Zero_ce0b69b0f9af6cbb->createContext());
CREATE_OP_CONTEXT(rel_Arc_b47d9f303bde53a1_op_ctxt,rel_Arc_b47d9f303bde53a1->createContext());
CREATE_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt,rel_Zero_802d75c8c4d7ef88->createContext());

                   #if defined _OPENMP && _OPENMP < 200805
                           auto count = std::distance(part.begin(), part.end());
                           auto base = part.begin();
                           pfor(int index  = 0; index < count; index++) {
                               auto it = base + index;
                   #else
                           pfor(auto it = part.begin(); it < part.end(); it++) {
                   #endif
                   try{
for(const auto& env0 : *it) {
if( rel_delta_One_cb75c6228d9f24de->contains(Tuple<RamDomain,1>{{ramBitCast(env0[1])}},READ_OP_CONTEXT(rel_delta_One_cb75c6228d9f24de_op_ctxt)) && !(rel_Zero_802d75c8c4d7ef88->contains(Tuple<RamDomain,1>{{ramBitCast(env0[0])}},READ_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt)))) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_new_Zero_ce0b69b0f9af6cbb->insert(tuple,READ_OP_CONTEXT(rel_new_Zero_ce0b69b0f9af6cbb_op_ctxt));
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
if(rel_new_One_4ca429d50d22d3c9->empty() && rel_new_Zero_ce0b69b0f9af6cbb->empty()) break;
[&](){
CREATE_OP_CONTEXT(rel_new_One_4ca429d50d22d3c9_op_ctxt,rel_new_One_4ca429d50d22d3c9->createContext());
CREATE_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt,rel_One_4507392ecc2d4a7d->createContext());
for(const auto& env0 : *rel_new_One_4ca429d50d22d3c9) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_One_4507392ecc2d4a7d->insert(tuple,READ_OP_CONTEXT(rel_One_4507392ecc2d4a7d_op_ctxt));
}
}
();std::swap(rel_delta_One_cb75c6228d9f24de, rel_new_One_4ca429d50d22d3c9);
rel_new_One_4ca429d50d22d3c9->purge();
[&](){
CREATE_OP_CONTEXT(rel_new_Zero_ce0b69b0f9af6cbb_op_ctxt,rel_new_Zero_ce0b69b0f9af6cbb->createContext());
CREATE_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt,rel_Zero_802d75c8c4d7ef88->createContext());
for(const auto& env0 : *rel_new_Zero_ce0b69b0f9af6cbb) {
Tuple<RamDomain,1> tuple{{ramBitCast(env0[0])}};
rel_Zero_802d75c8c4d7ef88->insert(tuple,READ_OP_CONTEXT(rel_Zero_802d75c8c4d7ef88_op_ctxt));
}
}
();std::swap(rel_delta_Zero_6b6447da41da1e01, rel_new_Zero_ce0b69b0f9af6cbb);
rel_new_Zero_ce0b69b0f9af6cbb->purge();
iter++;
}
iter = 0;
rel_delta_One_cb75c6228d9f24de->purge();
rel_new_One_4ca429d50d22d3c9->purge();
rel_delta_Zero_6b6447da41da1e01->purge();
rel_new_Zero_ce0b69b0f9af6cbb->purge();
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x"},{"auxArity","0"},{"name","One"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (outputDirectory == "-"){directiveMap["IO"] = "stdout"; directiveMap["headers"] = "true";}
else if (!outputDirectory.empty()) {directiveMap["output-dir"] = outputDirectory;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_One_4507392ecc2d4a7d);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x"},{"auxArity","0"},{"name","Zero"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (outputDirectory == "-"){directiveMap["IO"] = "stdout"; directiveMap["headers"] = "true";}
else if (!outputDirectory.empty()) {directiveMap["output-dir"] = outputDirectory;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_Zero_802d75c8c4d7ef88);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}
if (pruneImdtRels) rel_Arc_b47d9f303bde53a1->purge();
if (pruneImdtRels) rel_Source_724b8cde435eac4d->purge();
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_Source_ee2e7dc13ff2c53e {
public:
 Stratum_Source_ee2e7dc13ff2c53e(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_i__0__1::Type& rel_Source_724b8cde435eac4d);
void run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret);
private:
SymbolTable& symTable;
RecordTable& recordTable;
ConcurrentCache<std::string,std::regex>& regexCache;
bool& pruneImdtRels;
bool& performIO;
SignalHandler*& signalHandler;
std::atomic<std::size_t>& iter;
std::atomic<RamDomain>& ctr;
std::string& inputDirectory;
std::string& outputDirectory;
t_btree_i__0__1::Type* rel_Source_724b8cde435eac4d;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_Source_ee2e7dc13ff2c53e::Stratum_Source_ee2e7dc13ff2c53e(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_i__0__1::Type& rel_Source_724b8cde435eac4d):
symTable(symTable),
recordTable(recordTable),
regexCache(regexCache),
pruneImdtRels(pruneImdtRels),
performIO(performIO),
signalHandler(signalHandler),
iter(iter),
ctr(ctr),
inputDirectory(inputDirectory),
outputDirectory(outputDirectory),
rel_Source_724b8cde435eac4d(&rel_Source_724b8cde435eac4d){
}

void Stratum_Source_ee2e7dc13ff2c53e::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","x"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Source.csv"},{"name","Source"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Source_724b8cde435eac4d);
} catch (std::exception& e) {std::cerr << "Error loading Source data: " << e.what() << '\n';
exit(1);
}
}
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Sf_bipartite_monitor: public SouffleProgram {
public:
 Sf_bipartite_monitor();
 ~Sf_bipartite_monitor();
void run();
void runAll(std::string inputDirectoryArg = "",std::string outputDirectoryArg = "",bool performIOArg = true,bool pruneImdtRelsArg = true);
void printAll([[maybe_unused]] std::string outputDirectoryArg = "");
void loadAll([[maybe_unused]] std::string inputDirectoryArg = "");
void dumpInputs();
void dumpOutputs();
SymbolTable& getSymbolTable();
RecordTable& getRecordTable();
void setNumThreads(std::size_t numThreadsValue);
void executeSubroutine(std::string name,const std::vector<RamDomain>& args,std::vector<RamDomain>& ret);
private:
void runFunction(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg);
SymbolTableImpl symTable;
SpecializedRecordTable<0> recordTable;
ConcurrentCache<std::string,std::regex> regexCache;
Own<t_btree_ii__0_1__11::Type> rel_Arc_b47d9f303bde53a1;
souffle::RelationWrapper<t_btree_ii__0_1__11::Type> wrapper_rel_Arc_b47d9f303bde53a1;
Own<t_btree_i__0__1::Type> rel_Source_724b8cde435eac4d;
souffle::RelationWrapper<t_btree_i__0__1::Type> wrapper_rel_Source_724b8cde435eac4d;
Own<t_btree_i__0__1::Type> rel_One_4507392ecc2d4a7d;
souffle::RelationWrapper<t_btree_i__0__1::Type> wrapper_rel_One_4507392ecc2d4a7d;
Own<t_btree_i__0__1::Type> rel_delta_One_cb75c6228d9f24de;
Own<t_btree_i__0__1::Type> rel_new_One_4ca429d50d22d3c9;
Own<t_btree_i__0__1::Type> rel_Zero_802d75c8c4d7ef88;
souffle::RelationWrapper<t_btree_i__0__1::Type> wrapper_rel_Zero_802d75c8c4d7ef88;
Own<t_btree_i__0__1::Type> rel_delta_Zero_6b6447da41da1e01;
Own<t_btree_i__0__1::Type> rel_new_Zero_ce0b69b0f9af6cbb;
Own<t_btree_i__0__1::Type> rel_BipartiteViolation_a439a62602a351d9;
souffle::RelationWrapper<t_btree_i__0__1::Type> wrapper_rel_BipartiteViolation_a439a62602a351d9;
Stratum_Arc_52d74c4c48628683 stratum_Arc_0200bb182d11e669;
Stratum_BipartiteViolation_40f1ed098f44af96 stratum_BipartiteViolation_c43e538500167d3e;
Stratum_One_08d574766b0cbe45 stratum_One_7b754cf0e7e1f6ee;
Stratum_Source_ee2e7dc13ff2c53e stratum_Source_ad66afa194d6bfb9;
std::string inputDirectory;
std::string outputDirectory;
SignalHandler* signalHandler{SignalHandler::instance()};
std::atomic<RamDomain> ctr{};
std::atomic<std::size_t> iter{};
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Sf_bipartite_monitor::Sf_bipartite_monitor():
symTable(),
recordTable(),
regexCache(),
rel_Arc_b47d9f303bde53a1(mk<t_btree_ii__0_1__11::Type>()),
wrapper_rel_Arc_b47d9f303bde53a1(0, *rel_Arc_b47d9f303bde53a1, *this, "Arc", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"y","x"}}, 0),
rel_Source_724b8cde435eac4d(mk<t_btree_i__0__1::Type>()),
wrapper_rel_Source_724b8cde435eac4d(1, *rel_Source_724b8cde435eac4d, *this, "Source", std::array<const char *,1>{{"i:number"}}, std::array<const char *,1>{{"x"}}, 0),
rel_One_4507392ecc2d4a7d(mk<t_btree_i__0__1::Type>()),
wrapper_rel_One_4507392ecc2d4a7d(2, *rel_One_4507392ecc2d4a7d, *this, "One", std::array<const char *,1>{{"i:number"}}, std::array<const char *,1>{{"x"}}, 0),
rel_delta_One_cb75c6228d9f24de(mk<t_btree_i__0__1::Type>()),
rel_new_One_4ca429d50d22d3c9(mk<t_btree_i__0__1::Type>()),
rel_Zero_802d75c8c4d7ef88(mk<t_btree_i__0__1::Type>()),
wrapper_rel_Zero_802d75c8c4d7ef88(3, *rel_Zero_802d75c8c4d7ef88, *this, "Zero", std::array<const char *,1>{{"i:number"}}, std::array<const char *,1>{{"x"}}, 0),
rel_delta_Zero_6b6447da41da1e01(mk<t_btree_i__0__1::Type>()),
rel_new_Zero_ce0b69b0f9af6cbb(mk<t_btree_i__0__1::Type>()),
rel_BipartiteViolation_a439a62602a351d9(mk<t_btree_i__0__1::Type>()),
wrapper_rel_BipartiteViolation_a439a62602a351d9(4, *rel_BipartiteViolation_a439a62602a351d9, *this, "BipartiteViolation", std::array<const char *,1>{{"i:number"}}, std::array<const char *,1>{{"x"}}, 0),
stratum_Arc_0200bb182d11e669(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_Arc_b47d9f303bde53a1),
stratum_BipartiteViolation_c43e538500167d3e(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_BipartiteViolation_a439a62602a351d9,*rel_One_4507392ecc2d4a7d,*rel_Zero_802d75c8c4d7ef88),
stratum_One_7b754cf0e7e1f6ee(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_delta_One_cb75c6228d9f24de,*rel_delta_Zero_6b6447da41da1e01,*rel_new_One_4ca429d50d22d3c9,*rel_new_Zero_ce0b69b0f9af6cbb,*rel_Arc_b47d9f303bde53a1,*rel_One_4507392ecc2d4a7d,*rel_Source_724b8cde435eac4d,*rel_Zero_802d75c8c4d7ef88),
stratum_Source_ad66afa194d6bfb9(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_Source_724b8cde435eac4d){
addRelation("Arc", wrapper_rel_Arc_b47d9f303bde53a1, true, false);
addRelation("Source", wrapper_rel_Source_724b8cde435eac4d, true, false);
addRelation("One", wrapper_rel_One_4507392ecc2d4a7d, false, true);
addRelation("Zero", wrapper_rel_Zero_802d75c8c4d7ef88, false, true);
addRelation("BipartiteViolation", wrapper_rel_BipartiteViolation_a439a62602a351d9, false, true);
}

 Sf_bipartite_monitor::~Sf_bipartite_monitor(){
}

void Sf_bipartite_monitor::runFunction(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg){

    this->inputDirectory  = std::move(inputDirectoryArg);
    this->outputDirectory = std::move(outputDirectoryArg);
    this->performIO       = performIOArg;
    this->pruneImdtRels   = pruneImdtRelsArg;

    // set default threads (in embedded mode)
    // if this is not set, and omp is used, the default omp setting of number of cores is used.
#if defined(_OPENMP)
    if (0 < getNumThreads()) { omp_set_num_threads(static_cast<int>(getNumThreads())); }
#endif

    signalHandler->set();
// -- query evaluation --
{
 std::vector<RamDomain> args, ret;
stratum_Arc_0200bb182d11e669.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_Source_ad66afa194d6bfb9.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_One_7b754cf0e7e1f6ee.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_BipartiteViolation_c43e538500167d3e.run(args, ret);
}

// -- relation hint statistics --
signalHandler->reset();
}

void Sf_bipartite_monitor::run(){
runFunction("", "", false, false);
}

void Sf_bipartite_monitor::runAll(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg){
runFunction(inputDirectoryArg, outputDirectoryArg, performIOArg, pruneImdtRelsArg);
}

void Sf_bipartite_monitor::printAll([[maybe_unused]] std::string outputDirectoryArg){
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x"},{"auxArity","0"},{"name","One"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (!outputDirectoryArg.empty()) {directiveMap["output-dir"] = outputDirectoryArg;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_One_4507392ecc2d4a7d);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x"},{"auxArity","0"},{"name","Zero"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (!outputDirectoryArg.empty()) {directiveMap["output-dir"] = outputDirectoryArg;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_Zero_802d75c8c4d7ef88);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x"},{"auxArity","0"},{"name","BipartiteViolation"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (!outputDirectoryArg.empty()) {directiveMap["output-dir"] = outputDirectoryArg;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_BipartiteViolation_a439a62602a351d9);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

void Sf_bipartite_monitor::loadAll([[maybe_unused]] std::string inputDirectoryArg){
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","x"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Source.csv"},{"name","Source"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 1, \"params\": [\"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 1, \"types\": [\"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Source_724b8cde435eac4d);
} catch (std::exception& e) {std::cerr << "Error loading Source data: " << e.what() << '\n';
exit(1);
}
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","y,x"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Arc.csv"},{"name","Arc"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"y\", \"x\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Arc_b47d9f303bde53a1);
} catch (std::exception& e) {std::cerr << "Error loading Arc data: " << e.what() << '\n';
exit(1);
}
}

void Sf_bipartite_monitor::dumpInputs(){
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "Source";
rwOperation["types"] = "{\"relation\": {\"arity\": 1, \"auxArity\": 0, \"types\": [\"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_Source_724b8cde435eac4d);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "Arc";
rwOperation["types"] = "{\"relation\": {\"arity\": 2, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_Arc_b47d9f303bde53a1);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

void Sf_bipartite_monitor::dumpOutputs(){
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "One";
rwOperation["types"] = "{\"relation\": {\"arity\": 1, \"auxArity\": 0, \"types\": [\"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_One_4507392ecc2d4a7d);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "Zero";
rwOperation["types"] = "{\"relation\": {\"arity\": 1, \"auxArity\": 0, \"types\": [\"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_Zero_802d75c8c4d7ef88);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "BipartiteViolation";
rwOperation["types"] = "{\"relation\": {\"arity\": 1, \"auxArity\": 0, \"types\": [\"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_BipartiteViolation_a439a62602a351d9);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

SymbolTable& Sf_bipartite_monitor::getSymbolTable(){
return symTable;
}

RecordTable& Sf_bipartite_monitor::getRecordTable(){
return recordTable;
}

void Sf_bipartite_monitor::setNumThreads(std::size_t numThreadsValue){
SouffleProgram::setNumThreads(numThreadsValue);
symTable.setNumLanes(getNumThreads());
recordTable.setNumLanes(getNumThreads());
regexCache.setNumLanes(getNumThreads());
}

void Sf_bipartite_monitor::executeSubroutine(std::string name,const std::vector<RamDomain>& args,std::vector<RamDomain>& ret){
if (name == "Arc") {
stratum_Arc_0200bb182d11e669.run(args, ret);
return;}
if (name == "BipartiteViolation") {
stratum_BipartiteViolation_c43e538500167d3e.run(args, ret);
return;}
if (name == "One") {
stratum_One_7b754cf0e7e1f6ee.run(args, ret);
return;}
if (name == "Source") {
stratum_Source_ad66afa194d6bfb9.run(args, ret);
return;}
fatal(("unknown subroutine " + name).c_str());
}

} // namespace  souffle
namespace souffle {
SouffleProgram *newInstance_bipartite_monitor(){return new  souffle::Sf_bipartite_monitor;}
SymbolTable *getST_bipartite_monitor(SouffleProgram *p){return &reinterpret_cast<souffle::Sf_bipartite_monitor*>(p)->getSymbolTable();}
} // namespace souffle

#ifndef __EMBEDDED_SOUFFLE__
#include "souffle/CompiledOptions.h"
int main(int argc, char** argv)
{
try{
souffle::CmdOptions opt(R"(program/souffle/bipartite.dl)",
R"()",
R"()",
false,
R"()",
64);
if (!opt.parse(argc,argv)) return 1;
souffle::Sf_bipartite_monitor obj;
#if defined(_OPENMP) 
obj.setNumThreads(opt.getNumJobs());

#endif
obj.runAll(opt.getInputFileDir(), opt.getOutputFileDir());
return 0;
} catch(std::exception &e) { souffle::SignalHandler::instance()->error(e.what());}
}
#endif

namespace  souffle {
using namespace souffle;
class factory_Sf_bipartite_monitor: souffle::ProgramFactory {
public:
souffle::SouffleProgram* newInstance();
 factory_Sf_bipartite_monitor();
private:
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
souffle::SouffleProgram* factory_Sf_bipartite_monitor::newInstance(){
return new  souffle::Sf_bipartite_monitor();
}

 factory_Sf_bipartite_monitor::factory_Sf_bipartite_monitor():
souffle::ProgramFactory("bipartite_monitor"){
}

} // namespace  souffle
namespace souffle {

#ifdef __EMBEDDED_SOUFFLE__
extern "C" {
souffle::factory_Sf_bipartite_monitor __factory_Sf_bipartite_monitor_instance;
}
#endif
} // namespace souffle

