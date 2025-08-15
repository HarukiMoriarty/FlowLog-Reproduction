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
namespace souffle::t_btree_ii__0_1__11__10 {
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
range<t_ind_0::iterator> lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_0::iterator> lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper) const;
bool empty() const;
std::vector<range<iterator>> partition() const;
void purge();
iterator begin() const;
iterator end() const;
void printStatistics(std::ostream& o) const;
};
} // namespace souffle::t_btree_ii__0_1__11__10 
namespace souffle::t_btree_ii__0_1__11__10 {
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
range<t_ind_0::iterator> Type::lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper, context& h) const {
t_comparator_0 comparator;
int cmp = comparator(lower, upper);
if (cmp > 0) {
    return make_range(ind_0.end(), ind_0.end());
}
return make_range(ind_0.lower_bound(lower, h.hints_0_lower), ind_0.upper_bound(upper, h.hints_0_upper));
}
range<t_ind_0::iterator> Type::lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_10(lower,upper,h);
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
} // namespace souffle::t_btree_ii__0_1__11__10 
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
namespace  souffle {
using namespace souffle;
class Stratum_Edge_ece1e218b7cd378d {
public:
 Stratum_Edge_ece1e218b7cd378d(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11__10::Type& rel_Edge_4a6afad15efc54a7);
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
t_btree_ii__0_1__11__10::Type* rel_Edge_4a6afad15efc54a7;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_Edge_ece1e218b7cd378d::Stratum_Edge_ece1e218b7cd378d(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11__10::Type& rel_Edge_4a6afad15efc54a7):
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
rel_Edge_4a6afad15efc54a7(&rel_Edge_4a6afad15efc54a7){
}

void Stratum_Edge_ece1e218b7cd378d::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","x,y"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Edge.csv"},{"name","Edge"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"x\", \"y\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Edge_4a6afad15efc54a7);
} catch (std::exception& e) {std::cerr << "Error loading Edge data: " << e.what() << '\n';
exit(1);
}
}
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_NullEdge_1cee4b9251cbd449 {
public:
 Stratum_NullEdge_1cee4b9251cbd449(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_NullEdge_1369837d5d0fc749);
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
t_btree_ii__0_1__11::Type* rel_NullEdge_1369837d5d0fc749;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_NullEdge_1cee4b9251cbd449::Stratum_NullEdge_1cee4b9251cbd449(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_NullEdge_1369837d5d0fc749):
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
rel_NullEdge_1369837d5d0fc749(&rel_NullEdge_1369837d5d0fc749){
}

void Stratum_NullEdge_1cee4b9251cbd449::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","x,y"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","NullEdge.csv"},{"name","NullEdge"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"x\", \"y\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_NullEdge_1369837d5d0fc749);
} catch (std::exception& e) {std::cerr << "Error loading NullEdge data: " << e.what() << '\n';
exit(1);
}
}
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_NullNode_feff6f5a3954f429 {
public:
 Stratum_NullNode_feff6f5a3954f429(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_delta_NullNode_617dde22e9c47d25,t_btree_ii__0_1__11::Type& rel_new_NullNode_4a22257f9e095a07,t_btree_ii__0_1__11__10::Type& rel_Edge_4a6afad15efc54a7,t_btree_ii__0_1__11::Type& rel_NullEdge_1369837d5d0fc749,t_btree_ii__0_1__11::Type& rel_NullNode_a185bca79ed40c9a);
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
t_btree_ii__0_1__11::Type* rel_delta_NullNode_617dde22e9c47d25;
t_btree_ii__0_1__11::Type* rel_new_NullNode_4a22257f9e095a07;
t_btree_ii__0_1__11__10::Type* rel_Edge_4a6afad15efc54a7;
t_btree_ii__0_1__11::Type* rel_NullEdge_1369837d5d0fc749;
t_btree_ii__0_1__11::Type* rel_NullNode_a185bca79ed40c9a;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_NullNode_feff6f5a3954f429::Stratum_NullNode_feff6f5a3954f429(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_delta_NullNode_617dde22e9c47d25,t_btree_ii__0_1__11::Type& rel_new_NullNode_4a22257f9e095a07,t_btree_ii__0_1__11__10::Type& rel_Edge_4a6afad15efc54a7,t_btree_ii__0_1__11::Type& rel_NullEdge_1369837d5d0fc749,t_btree_ii__0_1__11::Type& rel_NullNode_a185bca79ed40c9a):
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
rel_delta_NullNode_617dde22e9c47d25(&rel_delta_NullNode_617dde22e9c47d25),
rel_new_NullNode_4a22257f9e095a07(&rel_new_NullNode_4a22257f9e095a07),
rel_Edge_4a6afad15efc54a7(&rel_Edge_4a6afad15efc54a7),
rel_NullEdge_1369837d5d0fc749(&rel_NullEdge_1369837d5d0fc749),
rel_NullNode_a185bca79ed40c9a(&rel_NullNode_a185bca79ed40c9a){
}

void Stratum_NullNode_feff6f5a3954f429::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
signalHandler->setMsg(R"_(NullNode(x,y) :- 
   NullEdge(x,y).
in file csda.dl [9:1-9:34])_");
if(!(rel_NullEdge_1369837d5d0fc749->empty())) {
[&](){
CREATE_OP_CONTEXT(rel_NullEdge_1369837d5d0fc749_op_ctxt,rel_NullEdge_1369837d5d0fc749->createContext());
CREATE_OP_CONTEXT(rel_NullNode_a185bca79ed40c9a_op_ctxt,rel_NullNode_a185bca79ed40c9a->createContext());
for(const auto& env0 : *rel_NullEdge_1369837d5d0fc749) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_NullNode_a185bca79ed40c9a->insert(tuple,READ_OP_CONTEXT(rel_NullNode_a185bca79ed40c9a_op_ctxt));
}
}
();}
[&](){
CREATE_OP_CONTEXT(rel_delta_NullNode_617dde22e9c47d25_op_ctxt,rel_delta_NullNode_617dde22e9c47d25->createContext());
CREATE_OP_CONTEXT(rel_NullNode_a185bca79ed40c9a_op_ctxt,rel_NullNode_a185bca79ed40c9a->createContext());
for(const auto& env0 : *rel_NullNode_a185bca79ed40c9a) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_delta_NullNode_617dde22e9c47d25->insert(tuple,READ_OP_CONTEXT(rel_delta_NullNode_617dde22e9c47d25_op_ctxt));
}
}
();iter = 0;
for(;;) {
signalHandler->setMsg(R"_(NullNode(x,y) :- 
   NullNode(x,w),
   Edge(w,y).
in file csda.dl [10:1-10:45])_");
if(!(rel_delta_NullNode_617dde22e9c47d25->empty()) && !(rel_Edge_4a6afad15efc54a7->empty())) {
[&](){
auto part = rel_delta_NullNode_617dde22e9c47d25->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_NullNode_617dde22e9c47d25_op_ctxt,rel_delta_NullNode_617dde22e9c47d25->createContext());
CREATE_OP_CONTEXT(rel_new_NullNode_4a22257f9e095a07_op_ctxt,rel_new_NullNode_4a22257f9e095a07->createContext());
CREATE_OP_CONTEXT(rel_Edge_4a6afad15efc54a7_op_ctxt,rel_Edge_4a6afad15efc54a7->createContext());
CREATE_OP_CONTEXT(rel_NullNode_a185bca79ed40c9a_op_ctxt,rel_NullNode_a185bca79ed40c9a->createContext());

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
auto range = rel_Edge_4a6afad15efc54a7->lowerUpperRange_10(Tuple<RamDomain,2>{{ramBitCast(env0[1]), ramBitCast<RamDomain>(MIN_RAM_SIGNED)}},Tuple<RamDomain,2>{{ramBitCast(env0[1]), ramBitCast<RamDomain>(MAX_RAM_SIGNED)}},READ_OP_CONTEXT(rel_Edge_4a6afad15efc54a7_op_ctxt));
for(const auto& env1 : range) {
if( !(rel_NullNode_a185bca79ed40c9a->contains(Tuple<RamDomain,2>{{ramBitCast(env0[0]),ramBitCast(env1[1])}},READ_OP_CONTEXT(rel_NullNode_a185bca79ed40c9a_op_ctxt)))) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env1[1])}};
rel_new_NullNode_4a22257f9e095a07->insert(tuple,READ_OP_CONTEXT(rel_new_NullNode_4a22257f9e095a07_op_ctxt));
}
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
if(rel_new_NullNode_4a22257f9e095a07->empty()) break;
[&](){
CREATE_OP_CONTEXT(rel_new_NullNode_4a22257f9e095a07_op_ctxt,rel_new_NullNode_4a22257f9e095a07->createContext());
CREATE_OP_CONTEXT(rel_NullNode_a185bca79ed40c9a_op_ctxt,rel_NullNode_a185bca79ed40c9a->createContext());
for(const auto& env0 : *rel_new_NullNode_4a22257f9e095a07) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_NullNode_a185bca79ed40c9a->insert(tuple,READ_OP_CONTEXT(rel_NullNode_a185bca79ed40c9a_op_ctxt));
}
}
();std::swap(rel_delta_NullNode_617dde22e9c47d25, rel_new_NullNode_4a22257f9e095a07);
rel_new_NullNode_4a22257f9e095a07->purge();
iter++;
}
iter = 0;
rel_delta_NullNode_617dde22e9c47d25->purge();
rel_new_NullNode_4a22257f9e095a07->purge();
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x\ty"},{"auxArity","0"},{"name","NullNode"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"x\", \"y\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (outputDirectory == "-"){directiveMap["IO"] = "stdout"; directiveMap["headers"] = "true";}
else if (!outputDirectory.empty()) {directiveMap["output-dir"] = outputDirectory;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_NullNode_a185bca79ed40c9a);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}
if (pruneImdtRels) rel_Edge_4a6afad15efc54a7->purge();
if (pruneImdtRels) rel_NullEdge_1369837d5d0fc749->purge();
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Sf_csda_souffle: public SouffleProgram {
public:
 Sf_csda_souffle();
 ~Sf_csda_souffle();
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
Own<t_btree_ii__0_1__11__10::Type> rel_Edge_4a6afad15efc54a7;
souffle::RelationWrapper<t_btree_ii__0_1__11__10::Type> wrapper_rel_Edge_4a6afad15efc54a7;
Own<t_btree_ii__0_1__11::Type> rel_NullEdge_1369837d5d0fc749;
souffle::RelationWrapper<t_btree_ii__0_1__11::Type> wrapper_rel_NullEdge_1369837d5d0fc749;
Own<t_btree_ii__0_1__11::Type> rel_NullNode_a185bca79ed40c9a;
souffle::RelationWrapper<t_btree_ii__0_1__11::Type> wrapper_rel_NullNode_a185bca79ed40c9a;
Own<t_btree_ii__0_1__11::Type> rel_delta_NullNode_617dde22e9c47d25;
Own<t_btree_ii__0_1__11::Type> rel_new_NullNode_4a22257f9e095a07;
Stratum_Edge_ece1e218b7cd378d stratum_Edge_41e8cd14d1fff213;
Stratum_NullEdge_1cee4b9251cbd449 stratum_NullEdge_ab0e0b98a12018d7;
Stratum_NullNode_feff6f5a3954f429 stratum_NullNode_e8fa2ae89d0b330d;
std::string inputDirectory;
std::string outputDirectory;
SignalHandler* signalHandler{SignalHandler::instance()};
std::atomic<RamDomain> ctr{};
std::atomic<std::size_t> iter{};
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Sf_csda_souffle::Sf_csda_souffle():
symTable(),
recordTable(),
regexCache(),
rel_Edge_4a6afad15efc54a7(mk<t_btree_ii__0_1__11__10::Type>()),
wrapper_rel_Edge_4a6afad15efc54a7(0, *rel_Edge_4a6afad15efc54a7, *this, "Edge", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"x","y"}}, 0),
rel_NullEdge_1369837d5d0fc749(mk<t_btree_ii__0_1__11::Type>()),
wrapper_rel_NullEdge_1369837d5d0fc749(1, *rel_NullEdge_1369837d5d0fc749, *this, "NullEdge", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"x","y"}}, 0),
rel_NullNode_a185bca79ed40c9a(mk<t_btree_ii__0_1__11::Type>()),
wrapper_rel_NullNode_a185bca79ed40c9a(2, *rel_NullNode_a185bca79ed40c9a, *this, "NullNode", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"x","y"}}, 0),
rel_delta_NullNode_617dde22e9c47d25(mk<t_btree_ii__0_1__11::Type>()),
rel_new_NullNode_4a22257f9e095a07(mk<t_btree_ii__0_1__11::Type>()),
stratum_Edge_41e8cd14d1fff213(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_Edge_4a6afad15efc54a7),
stratum_NullEdge_ab0e0b98a12018d7(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_NullEdge_1369837d5d0fc749),
stratum_NullNode_e8fa2ae89d0b330d(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_delta_NullNode_617dde22e9c47d25,*rel_new_NullNode_4a22257f9e095a07,*rel_Edge_4a6afad15efc54a7,*rel_NullEdge_1369837d5d0fc749,*rel_NullNode_a185bca79ed40c9a){
addRelation("Edge", wrapper_rel_Edge_4a6afad15efc54a7, true, false);
addRelation("NullEdge", wrapper_rel_NullEdge_1369837d5d0fc749, true, false);
addRelation("NullNode", wrapper_rel_NullNode_a185bca79ed40c9a, false, true);
}

 Sf_csda_souffle::~Sf_csda_souffle(){
}

void Sf_csda_souffle::runFunction(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg){

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
stratum_Edge_41e8cd14d1fff213.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_NullEdge_ab0e0b98a12018d7.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_NullNode_e8fa2ae89d0b330d.run(args, ret);
}

// -- relation hint statistics --
signalHandler->reset();
}

void Sf_csda_souffle::run(){
runFunction("", "", false, false);
}

void Sf_csda_souffle::runAll(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg){
runFunction(inputDirectoryArg, outputDirectoryArg, performIOArg, pruneImdtRelsArg);
}

void Sf_csda_souffle::printAll([[maybe_unused]] std::string outputDirectoryArg){
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","x\ty"},{"auxArity","0"},{"name","NullNode"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"x\", \"y\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!outputDirectoryArg.empty()) {directiveMap["output-dir"] = outputDirectoryArg;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_NullNode_a185bca79ed40c9a);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

void Sf_csda_souffle::loadAll([[maybe_unused]] std::string inputDirectoryArg){
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","x,y"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Edge.csv"},{"name","Edge"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"x\", \"y\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Edge_4a6afad15efc54a7);
} catch (std::exception& e) {std::cerr << "Error loading Edge data: " << e.what() << '\n';
exit(1);
}
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","x,y"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","NullEdge.csv"},{"name","NullEdge"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"x\", \"y\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_NullEdge_1369837d5d0fc749);
} catch (std::exception& e) {std::cerr << "Error loading NullEdge data: " << e.what() << '\n';
exit(1);
}
}

void Sf_csda_souffle::dumpInputs(){
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "Edge";
rwOperation["types"] = "{\"relation\": {\"arity\": 2, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_Edge_4a6afad15efc54a7);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "NullEdge";
rwOperation["types"] = "{\"relation\": {\"arity\": 2, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_NullEdge_1369837d5d0fc749);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

void Sf_csda_souffle::dumpOutputs(){
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "NullNode";
rwOperation["types"] = "{\"relation\": {\"arity\": 2, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_NullNode_a185bca79ed40c9a);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

SymbolTable& Sf_csda_souffle::getSymbolTable(){
return symTable;
}

RecordTable& Sf_csda_souffle::getRecordTable(){
return recordTable;
}

void Sf_csda_souffle::setNumThreads(std::size_t numThreadsValue){
SouffleProgram::setNumThreads(numThreadsValue);
symTable.setNumLanes(getNumThreads());
recordTable.setNumLanes(getNumThreads());
regexCache.setNumLanes(getNumThreads());
}

void Sf_csda_souffle::executeSubroutine(std::string name,const std::vector<RamDomain>& args,std::vector<RamDomain>& ret){
if (name == "Edge") {
stratum_Edge_41e8cd14d1fff213.run(args, ret);
return;}
if (name == "NullEdge") {
stratum_NullEdge_ab0e0b98a12018d7.run(args, ret);
return;}
if (name == "NullNode") {
stratum_NullNode_e8fa2ae89d0b330d.run(args, ret);
return;}
fatal(("unknown subroutine " + name).c_str());
}

} // namespace  souffle
namespace souffle {
SouffleProgram *newInstance_csda_souffle(){return new  souffle::Sf_csda_souffle;}
SymbolTable *getST_csda_souffle(SouffleProgram *p){return &reinterpret_cast<souffle::Sf_csda_souffle*>(p)->getSymbolTable();}
} // namespace souffle

#ifndef __EMBEDDED_SOUFFLE__
#include "souffle/CompiledOptions.h"
int main(int argc, char** argv)
{
try{
souffle::CmdOptions opt(R"(program/souffle/csda.dl)",
R"()",
R"()",
false,
R"()",
4);
if (!opt.parse(argc,argv)) return 1;
souffle::Sf_csda_souffle obj;
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
class factory_Sf_csda_souffle: souffle::ProgramFactory {
public:
souffle::SouffleProgram* newInstance();
 factory_Sf_csda_souffle();
private:
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
souffle::SouffleProgram* factory_Sf_csda_souffle::newInstance(){
return new  souffle::Sf_csda_souffle();
}

 factory_Sf_csda_souffle::factory_Sf_csda_souffle():
souffle::ProgramFactory("csda_souffle"){
}

} // namespace  souffle
namespace souffle {

#ifdef __EMBEDDED_SOUFFLE__
extern "C" {
souffle::factory_Sf_csda_souffle __factory_Sf_csda_souffle_instance;
}
#endif
} // namespace souffle

