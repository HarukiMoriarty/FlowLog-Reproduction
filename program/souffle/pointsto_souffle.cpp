#define SOUFFLE_GENERATOR_VERSION "2.4"
#include "souffle/CompiledSouffle.h"
#include "souffle/SignalHandler.h"
#include "souffle/SouffleInterface.h"
#include "souffle/datastructure/BTree.h"
#include "souffle/io/IOSystem.h"
#include "souffle/profile/Logger.h"
#include "souffle/profile/ProfileEvent.h"
#include <any>
namespace functors {
extern "C" {
}
} //namespace functors
namespace souffle::t_btree_iii__0_2_1__101__111 {
using namespace souffle;
struct Type {
static constexpr Relation::arity_type Arity = 3;
using t_tuple = Tuple<RamDomain, 3>;
struct t_comparator_0{
 int operator()(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0])) ? -1 : (ramBitCast<RamSigned>(a[0]) > ramBitCast<RamSigned>(b[0])) ? 1 :((ramBitCast<RamSigned>(a[2]) < ramBitCast<RamSigned>(b[2])) ? -1 : (ramBitCast<RamSigned>(a[2]) > ramBitCast<RamSigned>(b[2])) ? 1 :((ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1])) ? -1 : (ramBitCast<RamSigned>(a[1]) > ramBitCast<RamSigned>(b[1])) ? 1 :(0)));
 }
bool less(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0]))|| ((ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0])) && ((ramBitCast<RamSigned>(a[2]) < ramBitCast<RamSigned>(b[2]))|| ((ramBitCast<RamSigned>(a[2]) == ramBitCast<RamSigned>(b[2])) && ((ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1]))))));
 }
bool equal(const t_tuple& a, const t_tuple& b) const {
return (ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0]))&&(ramBitCast<RamSigned>(a[2]) == ramBitCast<RamSigned>(b[2]))&&(ramBitCast<RamSigned>(a[1]) == ramBitCast<RamSigned>(b[1]));
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
bool insert(RamDomain a0,RamDomain a1,RamDomain a2);
bool contains(const t_tuple& t, context& h) const;
bool contains(const t_tuple& t) const;
std::size_t size() const;
iterator find(const t_tuple& t, context& h) const;
iterator find(const t_tuple& t) const;
range<iterator> lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const;
range<iterator> lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */) const;
range<t_ind_0::iterator> lowerUpperRange_101(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_0::iterator> lowerUpperRange_101(const t_tuple& lower, const t_tuple& upper) const;
range<t_ind_0::iterator> lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_0::iterator> lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper) const;
bool empty() const;
std::vector<range<iterator>> partition() const;
void purge();
iterator begin() const;
iterator end() const;
void printStatistics(std::ostream& o) const;
};
} // namespace souffle::t_btree_iii__0_2_1__101__111 
namespace souffle::t_btree_iii__0_2_1__101__111 {
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
RamDomain data[3];
std::copy(ramDomain, ramDomain + 3, data);
const t_tuple& tuple = reinterpret_cast<const t_tuple&>(data);
context h;
return insert(tuple, h);
}
bool Type::insert(RamDomain a0,RamDomain a1,RamDomain a2) {
RamDomain data[3] = {a0,a1,a2};
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
range<iterator> Type::lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<iterator> Type::lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<t_ind_0::iterator> Type::lowerUpperRange_101(const t_tuple& lower, const t_tuple& upper, context& h) const {
t_comparator_0 comparator;
int cmp = comparator(lower, upper);
if (cmp > 0) {
    return make_range(ind_0.end(), ind_0.end());
}
return make_range(ind_0.lower_bound(lower, h.hints_0_lower), ind_0.upper_bound(upper, h.hints_0_upper));
}
range<t_ind_0::iterator> Type::lowerUpperRange_101(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_101(lower,upper,h);
}
range<t_ind_0::iterator> Type::lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper, context& h) const {
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
range<t_ind_0::iterator> Type::lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_111(lower,upper,h);
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
o << " arity 3 direct b-tree index 0 lex-order [0,2,1]\n";
ind_0.printStats(o);
}
} // namespace souffle::t_btree_iii__0_2_1__101__111 
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
namespace souffle::t_btree_iii__0_1_2__111 {
using namespace souffle;
struct Type {
static constexpr Relation::arity_type Arity = 3;
using t_tuple = Tuple<RamDomain, 3>;
struct t_comparator_0{
 int operator()(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0])) ? -1 : (ramBitCast<RamSigned>(a[0]) > ramBitCast<RamSigned>(b[0])) ? 1 :((ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1])) ? -1 : (ramBitCast<RamSigned>(a[1]) > ramBitCast<RamSigned>(b[1])) ? 1 :((ramBitCast<RamSigned>(a[2]) < ramBitCast<RamSigned>(b[2])) ? -1 : (ramBitCast<RamSigned>(a[2]) > ramBitCast<RamSigned>(b[2])) ? 1 :(0)));
 }
bool less(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0]))|| ((ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0])) && ((ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1]))|| ((ramBitCast<RamSigned>(a[1]) == ramBitCast<RamSigned>(b[1])) && ((ramBitCast<RamSigned>(a[2]) < ramBitCast<RamSigned>(b[2]))))));
 }
bool equal(const t_tuple& a, const t_tuple& b) const {
return (ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0]))&&(ramBitCast<RamSigned>(a[1]) == ramBitCast<RamSigned>(b[1]))&&(ramBitCast<RamSigned>(a[2]) == ramBitCast<RamSigned>(b[2]));
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
bool insert(RamDomain a0,RamDomain a1,RamDomain a2);
bool contains(const t_tuple& t, context& h) const;
bool contains(const t_tuple& t) const;
std::size_t size() const;
iterator find(const t_tuple& t, context& h) const;
iterator find(const t_tuple& t) const;
range<iterator> lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const;
range<iterator> lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */) const;
range<t_ind_0::iterator> lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_0::iterator> lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper) const;
bool empty() const;
std::vector<range<iterator>> partition() const;
void purge();
iterator begin() const;
iterator end() const;
void printStatistics(std::ostream& o) const;
};
} // namespace souffle::t_btree_iii__0_1_2__111 
namespace souffle::t_btree_iii__0_1_2__111 {
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
RamDomain data[3];
std::copy(ramDomain, ramDomain + 3, data);
const t_tuple& tuple = reinterpret_cast<const t_tuple&>(data);
context h;
return insert(tuple, h);
}
bool Type::insert(RamDomain a0,RamDomain a1,RamDomain a2) {
RamDomain data[3] = {a0,a1,a2};
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
range<iterator> Type::lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */, context& /* h */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<iterator> Type::lowerUpperRange_000(const t_tuple& /* lower */, const t_tuple& /* upper */) const {
return range<iterator>(ind_0.begin(),ind_0.end());
}
range<t_ind_0::iterator> Type::lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper, context& h) const {
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
range<t_ind_0::iterator> Type::lowerUpperRange_111(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_111(lower,upper,h);
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
o << " arity 3 direct b-tree index 0 lex-order [0,1,2]\n";
ind_0.printStats(o);
}
} // namespace souffle::t_btree_iii__0_1_2__111 
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
namespace souffle::t_btree_ii__1_0__0__11__10__01 {
using namespace souffle;
struct Type {
static constexpr Relation::arity_type Arity = 2;
using t_tuple = Tuple<RamDomain, 2>;
struct t_comparator_0{
 int operator()(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1])) ? -1 : (ramBitCast<RamSigned>(a[1]) > ramBitCast<RamSigned>(b[1])) ? 1 :((ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0])) ? -1 : (ramBitCast<RamSigned>(a[0]) > ramBitCast<RamSigned>(b[0])) ? 1 :(0));
 }
bool less(const t_tuple& a, const t_tuple& b) const {
  return (ramBitCast<RamSigned>(a[1]) < ramBitCast<RamSigned>(b[1]))|| ((ramBitCast<RamSigned>(a[1]) == ramBitCast<RamSigned>(b[1])) && ((ramBitCast<RamSigned>(a[0]) < ramBitCast<RamSigned>(b[0]))));
 }
bool equal(const t_tuple& a, const t_tuple& b) const {
return (ramBitCast<RamSigned>(a[1]) == ramBitCast<RamSigned>(b[1]))&&(ramBitCast<RamSigned>(a[0]) == ramBitCast<RamSigned>(b[0]));
 }
};
using t_ind_0 = btree_set<t_tuple,t_comparator_0>;
t_ind_0 ind_0;
struct t_comparator_1{
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
using t_ind_1 = btree_multiset<t_tuple,t_comparator_1>;
t_ind_1 ind_1;
using iterator = t_ind_0::iterator;
struct context {
t_ind_0::operation_hints hints_0_lower;
t_ind_0::operation_hints hints_0_upper;
t_ind_1::operation_hints hints_1_lower;
t_ind_1::operation_hints hints_1_upper;
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
range<t_ind_1::iterator> lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_1::iterator> lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper) const;
range<t_ind_0::iterator> lowerUpperRange_01(const t_tuple& lower, const t_tuple& upper, context& h) const;
range<t_ind_0::iterator> lowerUpperRange_01(const t_tuple& lower, const t_tuple& upper) const;
bool empty() const;
std::vector<range<iterator>> partition() const;
void purge();
iterator begin() const;
iterator end() const;
void printStatistics(std::ostream& o) const;
};
} // namespace souffle::t_btree_ii__1_0__0__11__10__01 
namespace souffle::t_btree_ii__1_0__0__11__10__01 {
using namespace souffle;
using t_ind_0 = Type::t_ind_0;
using t_ind_1 = Type::t_ind_1;
using iterator = Type::iterator;
using context = Type::context;
bool Type::insert(const t_tuple& t) {
context h;
return insert(t, h);
}
bool Type::insert(const t_tuple& t, context& h) {
if (ind_0.insert(t, h.hints_0_lower)) {
ind_1.insert(t, h.hints_1_lower);
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
range<t_ind_1::iterator> Type::lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper, context& h) const {
t_comparator_1 comparator;
int cmp = comparator(lower, upper);
if (cmp > 0) {
    return make_range(ind_1.end(), ind_1.end());
}
return make_range(ind_1.lower_bound(lower, h.hints_1_lower), ind_1.upper_bound(upper, h.hints_1_upper));
}
range<t_ind_1::iterator> Type::lowerUpperRange_10(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_10(lower,upper,h);
}
range<t_ind_0::iterator> Type::lowerUpperRange_01(const t_tuple& lower, const t_tuple& upper, context& h) const {
t_comparator_0 comparator;
int cmp = comparator(lower, upper);
if (cmp > 0) {
    return make_range(ind_0.end(), ind_0.end());
}
return make_range(ind_0.lower_bound(lower, h.hints_0_lower), ind_0.upper_bound(upper, h.hints_0_upper));
}
range<t_ind_0::iterator> Type::lowerUpperRange_01(const t_tuple& lower, const t_tuple& upper) const {
context h;
return lowerUpperRange_01(lower,upper,h);
}
bool Type::empty() const {
return ind_0.empty();
}
std::vector<range<iterator>> Type::partition() const {
return ind_0.getChunks(400);
}
void Type::purge() {
ind_0.clear();
ind_1.clear();
}
iterator Type::begin() const {
return ind_0.begin();
}
iterator Type::end() const {
return ind_0.end();
}
void Type::printStatistics(std::ostream& o) const {
o << " arity 2 direct b-tree index 0 lex-order [1,0]\n";
ind_0.printStats(o);
o << " arity 2 direct b-tree index 1 lex-order [0]\n";
ind_1.printStats(o);
}
} // namespace souffle::t_btree_ii__1_0__0__11__10__01 
namespace  souffle {
using namespace souffle;
class Stratum_Alias_0d78fab14e1b06fc {
public:
 Stratum_Alias_0d78fab14e1b06fc(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11__10::Type& rel_delta_Alias_8f4123873f20c8cf,t_btree_ii__0_1__11::Type& rel_delta_Assign_18d3b6e18cfd0f97,t_btree_ii__1_0__0__11__10__01::Type& rel_delta_VarPointsTo_16577dc30fb04e76,t_btree_ii__0_1__11__10::Type& rel_new_Alias_4e965446bd3cabe9,t_btree_ii__0_1__11::Type& rel_new_Assign_8d9a4451a73a497b,t_btree_ii__1_0__0__11__10__01::Type& rel_new_VarPointsTo_5ea2db765d05791c,t_btree_ii__0_1__11::Type& rel_Alias_22e56a91218d2f0d,t_btree_ii__0_1__11::Type& rel_Assign_fb9d653572c1dfb9,t_btree_ii__0_1__11::Type& rel_AssignAlloc_b325dcfc921b51d2,t_btree_iii__0_2_1__101__111::Type& rel_Load_410733f1f0b09d0c,t_btree_ii__0_1__11::Type& rel_PrimitiveAssign_a588bc61ab275f32,t_btree_iii__0_1_2__111::Type& rel_Store_fe2fea7187103d89,t_btree_ii__1_0__0__11__10__01::Type& rel_VarPointsTo_c1a9f897b9f324f0);
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
t_btree_ii__0_1__11__10::Type* rel_delta_Alias_8f4123873f20c8cf;
t_btree_ii__0_1__11::Type* rel_delta_Assign_18d3b6e18cfd0f97;
t_btree_ii__1_0__0__11__10__01::Type* rel_delta_VarPointsTo_16577dc30fb04e76;
t_btree_ii__0_1__11__10::Type* rel_new_Alias_4e965446bd3cabe9;
t_btree_ii__0_1__11::Type* rel_new_Assign_8d9a4451a73a497b;
t_btree_ii__1_0__0__11__10__01::Type* rel_new_VarPointsTo_5ea2db765d05791c;
t_btree_ii__0_1__11::Type* rel_Alias_22e56a91218d2f0d;
t_btree_ii__0_1__11::Type* rel_Assign_fb9d653572c1dfb9;
t_btree_ii__0_1__11::Type* rel_AssignAlloc_b325dcfc921b51d2;
t_btree_iii__0_2_1__101__111::Type* rel_Load_410733f1f0b09d0c;
t_btree_ii__0_1__11::Type* rel_PrimitiveAssign_a588bc61ab275f32;
t_btree_iii__0_1_2__111::Type* rel_Store_fe2fea7187103d89;
t_btree_ii__1_0__0__11__10__01::Type* rel_VarPointsTo_c1a9f897b9f324f0;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_Alias_0d78fab14e1b06fc::Stratum_Alias_0d78fab14e1b06fc(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11__10::Type& rel_delta_Alias_8f4123873f20c8cf,t_btree_ii__0_1__11::Type& rel_delta_Assign_18d3b6e18cfd0f97,t_btree_ii__1_0__0__11__10__01::Type& rel_delta_VarPointsTo_16577dc30fb04e76,t_btree_ii__0_1__11__10::Type& rel_new_Alias_4e965446bd3cabe9,t_btree_ii__0_1__11::Type& rel_new_Assign_8d9a4451a73a497b,t_btree_ii__1_0__0__11__10__01::Type& rel_new_VarPointsTo_5ea2db765d05791c,t_btree_ii__0_1__11::Type& rel_Alias_22e56a91218d2f0d,t_btree_ii__0_1__11::Type& rel_Assign_fb9d653572c1dfb9,t_btree_ii__0_1__11::Type& rel_AssignAlloc_b325dcfc921b51d2,t_btree_iii__0_2_1__101__111::Type& rel_Load_410733f1f0b09d0c,t_btree_ii__0_1__11::Type& rel_PrimitiveAssign_a588bc61ab275f32,t_btree_iii__0_1_2__111::Type& rel_Store_fe2fea7187103d89,t_btree_ii__1_0__0__11__10__01::Type& rel_VarPointsTo_c1a9f897b9f324f0):
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
rel_delta_Alias_8f4123873f20c8cf(&rel_delta_Alias_8f4123873f20c8cf),
rel_delta_Assign_18d3b6e18cfd0f97(&rel_delta_Assign_18d3b6e18cfd0f97),
rel_delta_VarPointsTo_16577dc30fb04e76(&rel_delta_VarPointsTo_16577dc30fb04e76),
rel_new_Alias_4e965446bd3cabe9(&rel_new_Alias_4e965446bd3cabe9),
rel_new_Assign_8d9a4451a73a497b(&rel_new_Assign_8d9a4451a73a497b),
rel_new_VarPointsTo_5ea2db765d05791c(&rel_new_VarPointsTo_5ea2db765d05791c),
rel_Alias_22e56a91218d2f0d(&rel_Alias_22e56a91218d2f0d),
rel_Assign_fb9d653572c1dfb9(&rel_Assign_fb9d653572c1dfb9),
rel_AssignAlloc_b325dcfc921b51d2(&rel_AssignAlloc_b325dcfc921b51d2),
rel_Load_410733f1f0b09d0c(&rel_Load_410733f1f0b09d0c),
rel_PrimitiveAssign_a588bc61ab275f32(&rel_PrimitiveAssign_a588bc61ab275f32),
rel_Store_fe2fea7187103d89(&rel_Store_fe2fea7187103d89),
rel_VarPointsTo_c1a9f897b9f324f0(&rel_VarPointsTo_c1a9f897b9f324f0){
}

void Stratum_Alias_0d78fab14e1b06fc::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
ProfileEventSingleton::instance().makeQuantityEvent( R"(@n-nonrecursive-relation;Alias;pointsto.dl [14:7-14:12];)",rel_Alias_22e56a91218d2f0d->size(),iter);{
	Logger logger(R"_(@t-nonrecursive-relation;Assign;pointsto.dl [15:7-15:13];)_",iter, [&](){return rel_Assign_fb9d653572c1dfb9->size();});
signalHandler->setMsg(R"_(Assign(var1,var2) :- 
   PrimitiveAssign(var1,var2).
in file pointsto.dl [17:1-18:30])_");
{
	Logger logger(R"_(@t-nonrecursive-rule;Assign;pointsto.dl [17:1-18:30];Assign(var1,var2) :- \n   PrimitiveAssign(var1,var2).;)_",iter, [&](){return rel_Assign_fb9d653572c1dfb9->size();});
if(!(rel_PrimitiveAssign_a588bc61ab275f32->empty())) {
[&](){
CREATE_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt,rel_Assign_fb9d653572c1dfb9->createContext());
CREATE_OP_CONTEXT(rel_PrimitiveAssign_a588bc61ab275f32_op_ctxt,rel_PrimitiveAssign_a588bc61ab275f32->createContext());
for(const auto& env0 : *rel_PrimitiveAssign_a588bc61ab275f32) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_Assign_fb9d653572c1dfb9->insert(tuple,READ_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt));
}
}
();}
}
}
{
	Logger logger(R"_(@t-nonrecursive-relation;VarPointsTo;pointsto.dl [13:7-13:18];)_",iter, [&](){return rel_VarPointsTo_c1a9f897b9f324f0->size();});
signalHandler->setMsg(R"_(VarPointsTo(var,heap) :- 
   AssignAlloc(var,heap).
in file pointsto.dl [24:1-25:26])_");
{
	Logger logger(R"_(@t-nonrecursive-rule;VarPointsTo;pointsto.dl [24:1-25:26];VarPointsTo(var,heap) :- \n   AssignAlloc(var,heap).;)_",iter, [&](){return rel_VarPointsTo_c1a9f897b9f324f0->size();});
if(!(rel_AssignAlloc_b325dcfc921b51d2->empty())) {
[&](){
CREATE_OP_CONTEXT(rel_AssignAlloc_b325dcfc921b51d2_op_ctxt,rel_AssignAlloc_b325dcfc921b51d2->createContext());
CREATE_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt,rel_VarPointsTo_c1a9f897b9f324f0->createContext());
for(const auto& env0 : *rel_AssignAlloc_b325dcfc921b51d2) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_VarPointsTo_c1a9f897b9f324f0->insert(tuple,READ_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt));
}
}
();}
}
}
[&](){
CREATE_OP_CONTEXT(rel_delta_Alias_8f4123873f20c8cf_op_ctxt,rel_delta_Alias_8f4123873f20c8cf->createContext());
CREATE_OP_CONTEXT(rel_Alias_22e56a91218d2f0d_op_ctxt,rel_Alias_22e56a91218d2f0d->createContext());
for(const auto& env0 : *rel_Alias_22e56a91218d2f0d) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_delta_Alias_8f4123873f20c8cf->insert(tuple,READ_OP_CONTEXT(rel_delta_Alias_8f4123873f20c8cf_op_ctxt));
}
}
();[&](){
CREATE_OP_CONTEXT(rel_delta_Assign_18d3b6e18cfd0f97_op_ctxt,rel_delta_Assign_18d3b6e18cfd0f97->createContext());
CREATE_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt,rel_Assign_fb9d653572c1dfb9->createContext());
for(const auto& env0 : *rel_Assign_fb9d653572c1dfb9) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_delta_Assign_18d3b6e18cfd0f97->insert(tuple,READ_OP_CONTEXT(rel_delta_Assign_18d3b6e18cfd0f97_op_ctxt));
}
}
();[&](){
CREATE_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt,rel_delta_VarPointsTo_16577dc30fb04e76->createContext());
CREATE_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt,rel_VarPointsTo_c1a9f897b9f324f0->createContext());
for(const auto& env0 : *rel_VarPointsTo_c1a9f897b9f324f0) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_delta_VarPointsTo_16577dc30fb04e76->insert(tuple,READ_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt));
}
}
();iter = 0;
for(;;) {
{
	Logger logger(R"_(@t-recursive-relation;Alias;pointsto.dl [14:7-14:12];)_",iter, [&](){return rel_new_Alias_4e965446bd3cabe9->size();});
signalHandler->setMsg(R"_(Alias(instanceVar,iVar) :- 
   VarPointsTo(instanceVar,instanceHeap),
   VarPointsTo(iVar,instanceHeap).
in file pointsto.dl [20:1-22:35])_");
{
	Logger logger(R"_(@t-recursive-rule;Alias;0;pointsto.dl [20:1-22:35];Alias(instanceVar,iVar) :- \n   VarPointsTo(instanceVar,instanceHeap),\n   VarPointsTo(iVar,instanceHeap).;)_",iter, [&](){return rel_new_Alias_4e965446bd3cabe9->size();});
if(!(rel_delta_VarPointsTo_16577dc30fb04e76->empty()) && !(rel_VarPointsTo_c1a9f897b9f324f0->empty())) {
[&](){
auto part = rel_delta_VarPointsTo_16577dc30fb04e76->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt,rel_delta_VarPointsTo_16577dc30fb04e76->createContext());
CREATE_OP_CONTEXT(rel_new_Alias_4e965446bd3cabe9_op_ctxt,rel_new_Alias_4e965446bd3cabe9->createContext());
CREATE_OP_CONTEXT(rel_Alias_22e56a91218d2f0d_op_ctxt,rel_Alias_22e56a91218d2f0d->createContext());
CREATE_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt,rel_VarPointsTo_c1a9f897b9f324f0->createContext());

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
auto range = rel_VarPointsTo_c1a9f897b9f324f0->lowerUpperRange_01(Tuple<RamDomain,2>{{ramBitCast<RamDomain>(MIN_RAM_SIGNED), ramBitCast(env0[1])}},Tuple<RamDomain,2>{{ramBitCast<RamDomain>(MAX_RAM_SIGNED), ramBitCast(env0[1])}},READ_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt));
for(const auto& env1 : range) {
if( !(rel_Alias_22e56a91218d2f0d->contains(Tuple<RamDomain,2>{{ramBitCast(env0[0]),ramBitCast(env1[0])}},READ_OP_CONTEXT(rel_Alias_22e56a91218d2f0d_op_ctxt))) && !(rel_delta_VarPointsTo_16577dc30fb04e76->contains(Tuple<RamDomain,2>{{ramBitCast(env1[0]),ramBitCast(env0[1])}},READ_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt)))) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env1[0])}};
rel_new_Alias_4e965446bd3cabe9->insert(tuple,READ_OP_CONTEXT(rel_new_Alias_4e965446bd3cabe9_op_ctxt));
}
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
}
signalHandler->setMsg(R"_(Alias(instanceVar,iVar) :- 
   VarPointsTo(instanceVar,instanceHeap),
   VarPointsTo(iVar,instanceHeap).
in file pointsto.dl [20:1-22:35])_");
{
	Logger logger(R"_(@t-recursive-rule;Alias;1;pointsto.dl [20:1-22:35];Alias(instanceVar,iVar) :- \n   VarPointsTo(instanceVar,instanceHeap),\n   VarPointsTo(iVar,instanceHeap).;)_",iter, [&](){return rel_new_Alias_4e965446bd3cabe9->size();});
if(!(rel_VarPointsTo_c1a9f897b9f324f0->empty()) && !(rel_delta_VarPointsTo_16577dc30fb04e76->empty())) {
[&](){
auto part = rel_VarPointsTo_c1a9f897b9f324f0->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt,rel_delta_VarPointsTo_16577dc30fb04e76->createContext());
CREATE_OP_CONTEXT(rel_new_Alias_4e965446bd3cabe9_op_ctxt,rel_new_Alias_4e965446bd3cabe9->createContext());
CREATE_OP_CONTEXT(rel_Alias_22e56a91218d2f0d_op_ctxt,rel_Alias_22e56a91218d2f0d->createContext());
CREATE_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt,rel_VarPointsTo_c1a9f897b9f324f0->createContext());

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
auto range = rel_delta_VarPointsTo_16577dc30fb04e76->lowerUpperRange_01(Tuple<RamDomain,2>{{ramBitCast<RamDomain>(MIN_RAM_SIGNED), ramBitCast(env0[1])}},Tuple<RamDomain,2>{{ramBitCast<RamDomain>(MAX_RAM_SIGNED), ramBitCast(env0[1])}},READ_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt));
for(const auto& env1 : range) {
if( !(rel_Alias_22e56a91218d2f0d->contains(Tuple<RamDomain,2>{{ramBitCast(env0[0]),ramBitCast(env1[0])}},READ_OP_CONTEXT(rel_Alias_22e56a91218d2f0d_op_ctxt)))) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env1[0])}};
rel_new_Alias_4e965446bd3cabe9->insert(tuple,READ_OP_CONTEXT(rel_new_Alias_4e965446bd3cabe9_op_ctxt));
}
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
}
}
{
	Logger logger(R"_(@t-recursive-relation;Assign;pointsto.dl [15:7-15:13];)_",iter, [&](){return rel_new_Assign_8d9a4451a73a497b->size();});
signalHandler->setMsg(R"_(Assign(var1,var2) :- 
   Store(var1,instanceVar2,field),
   Alias(instanceVar2,instanceVar1),
   Load(instanceVar1,var2,field).
in file pointsto.dl [31:1-34:35])_");
{
	Logger logger(R"_(@t-recursive-rule;Assign;0;pointsto.dl [31:1-34:35];Assign(var1,var2) :- \n   Store(var1,instanceVar2,field),\n   Alias(instanceVar2,instanceVar1),\n   Load(instanceVar1,var2,field).;)_",iter, [&](){return rel_new_Assign_8d9a4451a73a497b->size();});
if(!(rel_delta_Alias_8f4123873f20c8cf->empty()) && !(rel_Load_410733f1f0b09d0c->empty()) && !(rel_Store_fe2fea7187103d89->empty())) {
[&](){
auto part = rel_Store_fe2fea7187103d89->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_Alias_8f4123873f20c8cf_op_ctxt,rel_delta_Alias_8f4123873f20c8cf->createContext());
CREATE_OP_CONTEXT(rel_new_Assign_8d9a4451a73a497b_op_ctxt,rel_new_Assign_8d9a4451a73a497b->createContext());
CREATE_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt,rel_Assign_fb9d653572c1dfb9->createContext());
CREATE_OP_CONTEXT(rel_Load_410733f1f0b09d0c_op_ctxt,rel_Load_410733f1f0b09d0c->createContext());
CREATE_OP_CONTEXT(rel_Store_fe2fea7187103d89_op_ctxt,rel_Store_fe2fea7187103d89->createContext());

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
auto range = rel_delta_Alias_8f4123873f20c8cf->lowerUpperRange_10(Tuple<RamDomain,2>{{ramBitCast(env0[1]), ramBitCast<RamDomain>(MIN_RAM_SIGNED)}},Tuple<RamDomain,2>{{ramBitCast(env0[1]), ramBitCast<RamDomain>(MAX_RAM_SIGNED)}},READ_OP_CONTEXT(rel_delta_Alias_8f4123873f20c8cf_op_ctxt));
for(const auto& env1 : range) {
auto range = rel_Load_410733f1f0b09d0c->lowerUpperRange_101(Tuple<RamDomain,3>{{ramBitCast(env1[1]), ramBitCast<RamDomain>(MIN_RAM_SIGNED), ramBitCast(env0[2])}},Tuple<RamDomain,3>{{ramBitCast(env1[1]), ramBitCast<RamDomain>(MAX_RAM_SIGNED), ramBitCast(env0[2])}},READ_OP_CONTEXT(rel_Load_410733f1f0b09d0c_op_ctxt));
for(const auto& env2 : range) {
if( !(rel_Assign_fb9d653572c1dfb9->contains(Tuple<RamDomain,2>{{ramBitCast(env0[0]),ramBitCast(env2[1])}},READ_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt)))) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env2[1])}};
rel_new_Assign_8d9a4451a73a497b->insert(tuple,READ_OP_CONTEXT(rel_new_Assign_8d9a4451a73a497b_op_ctxt));
}
}
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
}
}
{
	Logger logger(R"_(@t-recursive-relation;VarPointsTo;pointsto.dl [13:7-13:18];)_",iter, [&](){return rel_new_VarPointsTo_5ea2db765d05791c->size();});
signalHandler->setMsg(R"_(VarPointsTo(var1,heap) :- 
   Assign(var2,var1),
   VarPointsTo(var2,heap).
in file pointsto.dl [27:1-29:27])_");
{
	Logger logger(R"_(@t-recursive-rule;VarPointsTo;0;pointsto.dl [27:1-29:27];VarPointsTo(var1,heap) :- \n   Assign(var2,var1),\n   VarPointsTo(var2,heap).;)_",iter, [&](){return rel_new_VarPointsTo_5ea2db765d05791c->size();});
if(!(rel_delta_Assign_18d3b6e18cfd0f97->empty()) && !(rel_VarPointsTo_c1a9f897b9f324f0->empty())) {
[&](){
auto part = rel_delta_Assign_18d3b6e18cfd0f97->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_Assign_18d3b6e18cfd0f97_op_ctxt,rel_delta_Assign_18d3b6e18cfd0f97->createContext());
CREATE_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt,rel_delta_VarPointsTo_16577dc30fb04e76->createContext());
CREATE_OP_CONTEXT(rel_new_VarPointsTo_5ea2db765d05791c_op_ctxt,rel_new_VarPointsTo_5ea2db765d05791c->createContext());
CREATE_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt,rel_VarPointsTo_c1a9f897b9f324f0->createContext());

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
auto range = rel_VarPointsTo_c1a9f897b9f324f0->lowerUpperRange_10(Tuple<RamDomain,2>{{ramBitCast(env0[0]), ramBitCast<RamDomain>(MIN_RAM_SIGNED)}},Tuple<RamDomain,2>{{ramBitCast(env0[0]), ramBitCast<RamDomain>(MAX_RAM_SIGNED)}},READ_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt));
for(const auto& env1 : range) {
if( !(rel_VarPointsTo_c1a9f897b9f324f0->contains(Tuple<RamDomain,2>{{ramBitCast(env0[1]),ramBitCast(env1[1])}},READ_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt))) && !(rel_delta_VarPointsTo_16577dc30fb04e76->contains(Tuple<RamDomain,2>{{ramBitCast(env0[0]),ramBitCast(env1[1])}},READ_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt)))) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[1]),ramBitCast(env1[1])}};
rel_new_VarPointsTo_5ea2db765d05791c->insert(tuple,READ_OP_CONTEXT(rel_new_VarPointsTo_5ea2db765d05791c_op_ctxt));
}
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
}
signalHandler->setMsg(R"_(VarPointsTo(var1,heap) :- 
   Assign(var2,var1),
   VarPointsTo(var2,heap).
in file pointsto.dl [27:1-29:27])_");
{
	Logger logger(R"_(@t-recursive-rule;VarPointsTo;1;pointsto.dl [27:1-29:27];VarPointsTo(var1,heap) :- \n   Assign(var2,var1),\n   VarPointsTo(var2,heap).;)_",iter, [&](){return rel_new_VarPointsTo_5ea2db765d05791c->size();});
if(!(rel_Assign_fb9d653572c1dfb9->empty()) && !(rel_delta_VarPointsTo_16577dc30fb04e76->empty())) {
[&](){
auto part = rel_Assign_fb9d653572c1dfb9->partition();
PARALLEL_START
CREATE_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt,rel_delta_VarPointsTo_16577dc30fb04e76->createContext());
CREATE_OP_CONTEXT(rel_new_VarPointsTo_5ea2db765d05791c_op_ctxt,rel_new_VarPointsTo_5ea2db765d05791c->createContext());
CREATE_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt,rel_Assign_fb9d653572c1dfb9->createContext());
CREATE_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt,rel_VarPointsTo_c1a9f897b9f324f0->createContext());

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
auto range = rel_delta_VarPointsTo_16577dc30fb04e76->lowerUpperRange_10(Tuple<RamDomain,2>{{ramBitCast(env0[0]), ramBitCast<RamDomain>(MIN_RAM_SIGNED)}},Tuple<RamDomain,2>{{ramBitCast(env0[0]), ramBitCast<RamDomain>(MAX_RAM_SIGNED)}},READ_OP_CONTEXT(rel_delta_VarPointsTo_16577dc30fb04e76_op_ctxt));
for(const auto& env1 : range) {
if( !(rel_VarPointsTo_c1a9f897b9f324f0->contains(Tuple<RamDomain,2>{{ramBitCast(env0[1]),ramBitCast(env1[1])}},READ_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt)))) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[1]),ramBitCast(env1[1])}};
rel_new_VarPointsTo_5ea2db765d05791c->insert(tuple,READ_OP_CONTEXT(rel_new_VarPointsTo_5ea2db765d05791c_op_ctxt));
}
}
}
} catch(std::exception &e) { signalHandler->error(e.what());}
}
PARALLEL_END
}
();}
}
}
{
	Logger logger(R"_(@t-recursive-relation;Alias;pointsto.dl [14:7-14:12];)_",iter, [&](){return rel_new_Alias_4e965446bd3cabe9->size();});
}
{
	Logger logger(R"_(@t-recursive-relation;Assign;pointsto.dl [15:7-15:13];)_",iter, [&](){return rel_new_Assign_8d9a4451a73a497b->size();});
}
{
	Logger logger(R"_(@t-recursive-relation;VarPointsTo;pointsto.dl [13:7-13:18];)_",iter, [&](){return rel_new_VarPointsTo_5ea2db765d05791c->size();});
}
if(rel_new_Alias_4e965446bd3cabe9->empty() && rel_new_Assign_8d9a4451a73a497b->empty() && rel_new_VarPointsTo_5ea2db765d05791c->empty()) break;
{
	Logger logger(R"_(@c-recursive-relation;Alias;pointsto.dl [14:7-14:12];)_",iter, [&](){return rel_new_Alias_4e965446bd3cabe9->size();});
[&](){
CREATE_OP_CONTEXT(rel_new_Alias_4e965446bd3cabe9_op_ctxt,rel_new_Alias_4e965446bd3cabe9->createContext());
CREATE_OP_CONTEXT(rel_Alias_22e56a91218d2f0d_op_ctxt,rel_Alias_22e56a91218d2f0d->createContext());
for(const auto& env0 : *rel_new_Alias_4e965446bd3cabe9) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_Alias_22e56a91218d2f0d->insert(tuple,READ_OP_CONTEXT(rel_Alias_22e56a91218d2f0d_op_ctxt));
}
}
();std::swap(rel_delta_Alias_8f4123873f20c8cf, rel_new_Alias_4e965446bd3cabe9);
rel_new_Alias_4e965446bd3cabe9->purge();
}
{
	Logger logger(R"_(@c-recursive-relation;Assign;pointsto.dl [15:7-15:13];)_",iter, [&](){return rel_new_Assign_8d9a4451a73a497b->size();});
[&](){
CREATE_OP_CONTEXT(rel_new_Assign_8d9a4451a73a497b_op_ctxt,rel_new_Assign_8d9a4451a73a497b->createContext());
CREATE_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt,rel_Assign_fb9d653572c1dfb9->createContext());
for(const auto& env0 : *rel_new_Assign_8d9a4451a73a497b) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_Assign_fb9d653572c1dfb9->insert(tuple,READ_OP_CONTEXT(rel_Assign_fb9d653572c1dfb9_op_ctxt));
}
}
();std::swap(rel_delta_Assign_18d3b6e18cfd0f97, rel_new_Assign_8d9a4451a73a497b);
rel_new_Assign_8d9a4451a73a497b->purge();
}
{
	Logger logger(R"_(@c-recursive-relation;VarPointsTo;pointsto.dl [13:7-13:18];)_",iter, [&](){return rel_new_VarPointsTo_5ea2db765d05791c->size();});
[&](){
CREATE_OP_CONTEXT(rel_new_VarPointsTo_5ea2db765d05791c_op_ctxt,rel_new_VarPointsTo_5ea2db765d05791c->createContext());
CREATE_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt,rel_VarPointsTo_c1a9f897b9f324f0->createContext());
for(const auto& env0 : *rel_new_VarPointsTo_5ea2db765d05791c) {
Tuple<RamDomain,2> tuple{{ramBitCast(env0[0]),ramBitCast(env0[1])}};
rel_VarPointsTo_c1a9f897b9f324f0->insert(tuple,READ_OP_CONTEXT(rel_VarPointsTo_c1a9f897b9f324f0_op_ctxt));
}
}
();std::swap(rel_delta_VarPointsTo_16577dc30fb04e76, rel_new_VarPointsTo_5ea2db765d05791c);
rel_new_VarPointsTo_5ea2db765d05791c->purge();
}
iter++;
}
iter = 0;
rel_delta_Alias_8f4123873f20c8cf->purge();
rel_new_Alias_4e965446bd3cabe9->purge();
rel_delta_Assign_18d3b6e18cfd0f97->purge();
rel_new_Assign_8d9a4451a73a497b->purge();
rel_delta_VarPointsTo_16577dc30fb04e76->purge();
rel_new_VarPointsTo_5ea2db765d05791c->purge();
{
	Logger logger(R"_(@t-relation-savetime;Assign;pointsto.dl [15:7-15:13];savetime;)_",iter, [&](){return rel_Assign_fb9d653572c1dfb9->size();});
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","source\tdestination"},{"auxArity","0"},{"name","Assign"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"source\", \"destination\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (outputDirectory == "-"){directiveMap["IO"] = "stdout"; directiveMap["headers"] = "true";}
else if (!outputDirectory.empty()) {directiveMap["output-dir"] = outputDirectory;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_Assign_fb9d653572c1dfb9);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}
}
if (pruneImdtRels) rel_Alias_22e56a91218d2f0d->purge();
if (pruneImdtRels) rel_AssignAlloc_b325dcfc921b51d2->purge();
if (pruneImdtRels) rel_Load_410733f1f0b09d0c->purge();
if (pruneImdtRels) rel_PrimitiveAssign_a588bc61ab275f32->purge();
if (pruneImdtRels) rel_Store_fe2fea7187103d89->purge();
if (pruneImdtRels) rel_VarPointsTo_c1a9f897b9f324f0->purge();
}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_AssignAlloc_6559eedfd36944f8 {
public:
 Stratum_AssignAlloc_6559eedfd36944f8(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_AssignAlloc_b325dcfc921b51d2);
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
t_btree_ii__0_1__11::Type* rel_AssignAlloc_b325dcfc921b51d2;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_AssignAlloc_6559eedfd36944f8::Stratum_AssignAlloc_6559eedfd36944f8(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_AssignAlloc_b325dcfc921b51d2):
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
rel_AssignAlloc_b325dcfc921b51d2(&rel_AssignAlloc_b325dcfc921b51d2){
}

void Stratum_AssignAlloc_6559eedfd36944f8::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
{
	Logger logger(R"_(@t-relation-loadtime;AssignAlloc;pointsto.dl [1:7-1:18];loadtime;)_",iter, [&](){return rel_AssignAlloc_b325dcfc921b51d2->size();});
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","var,heap"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","AssignAlloc.csv"},{"name","AssignAlloc"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"var\", \"heap\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_AssignAlloc_b325dcfc921b51d2);
} catch (std::exception& e) {std::cerr << "Error loading AssignAlloc data: " << e.what() << '\n';
exit(1);
}
}
}
ProfileEventSingleton::instance().makeQuantityEvent( R"(@n-nonrecursive-relation;AssignAlloc;pointsto.dl [1:7-1:18];)",rel_AssignAlloc_b325dcfc921b51d2->size(),iter);}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_Load_5eb95f150d0bf803 {
public:
 Stratum_Load_5eb95f150d0bf803(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_iii__0_2_1__101__111::Type& rel_Load_410733f1f0b09d0c);
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
t_btree_iii__0_2_1__101__111::Type* rel_Load_410733f1f0b09d0c;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_Load_5eb95f150d0bf803::Stratum_Load_5eb95f150d0bf803(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_iii__0_2_1__101__111::Type& rel_Load_410733f1f0b09d0c):
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
rel_Load_410733f1f0b09d0c(&rel_Load_410733f1f0b09d0c){
}

void Stratum_Load_5eb95f150d0bf803::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
{
	Logger logger(R"_(@t-relation-loadtime;Load;pointsto.dl [7:7-7:11];loadtime;)_",iter, [&](){return rel_Load_410733f1f0b09d0c->size();});
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","base,dest,field"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Load.csv"},{"name","Load"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 3, \"params\": [\"base\", \"dest\", \"field\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 3, \"types\": [\"i:number\", \"i:number\", \"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Load_410733f1f0b09d0c);
} catch (std::exception& e) {std::cerr << "Error loading Load data: " << e.what() << '\n';
exit(1);
}
}
}
ProfileEventSingleton::instance().makeQuantityEvent( R"(@n-nonrecursive-relation;Load;pointsto.dl [7:7-7:11];)",rel_Load_410733f1f0b09d0c->size(),iter);}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_PrimitiveAssign_d5bded1efa0ba9ae {
public:
 Stratum_PrimitiveAssign_d5bded1efa0ba9ae(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_PrimitiveAssign_a588bc61ab275f32);
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
t_btree_ii__0_1__11::Type* rel_PrimitiveAssign_a588bc61ab275f32;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_PrimitiveAssign_d5bded1efa0ba9ae::Stratum_PrimitiveAssign_d5bded1efa0ba9ae(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_ii__0_1__11::Type& rel_PrimitiveAssign_a588bc61ab275f32):
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
rel_PrimitiveAssign_a588bc61ab275f32(&rel_PrimitiveAssign_a588bc61ab275f32){
}

void Stratum_PrimitiveAssign_d5bded1efa0ba9ae::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
{
	Logger logger(R"_(@t-relation-loadtime;PrimitiveAssign;pointsto.dl [4:7-4:22];loadtime;)_",iter, [&](){return rel_PrimitiveAssign_a588bc61ab275f32->size();});
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","source,dest"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","PrimitiveAssign.csv"},{"name","PrimitiveAssign"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"source\", \"dest\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_PrimitiveAssign_a588bc61ab275f32);
} catch (std::exception& e) {std::cerr << "Error loading PrimitiveAssign data: " << e.what() << '\n';
exit(1);
}
}
}
ProfileEventSingleton::instance().makeQuantityEvent( R"(@n-nonrecursive-relation;PrimitiveAssign;pointsto.dl [4:7-4:22];)",rel_PrimitiveAssign_a588bc61ab275f32->size(),iter);}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Stratum_Store_64290d23918eb1da {
public:
 Stratum_Store_64290d23918eb1da(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_iii__0_1_2__111::Type& rel_Store_fe2fea7187103d89);
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
t_btree_iii__0_1_2__111::Type* rel_Store_fe2fea7187103d89;
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Stratum_Store_64290d23918eb1da::Stratum_Store_64290d23918eb1da(SymbolTable& symTable,RecordTable& recordTable,ConcurrentCache<std::string,std::regex>& regexCache,bool& pruneImdtRels,bool& performIO,SignalHandler*& signalHandler,std::atomic<std::size_t>& iter,std::atomic<RamDomain>& ctr,std::string& inputDirectory,std::string& outputDirectory,t_btree_iii__0_1_2__111::Type& rel_Store_fe2fea7187103d89):
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
rel_Store_fe2fea7187103d89(&rel_Store_fe2fea7187103d89){
}

void Stratum_Store_64290d23918eb1da::run([[maybe_unused]] const std::vector<RamDomain>& args,[[maybe_unused]] std::vector<RamDomain>& ret){
{
	Logger logger(R"_(@t-relation-loadtime;Store;pointsto.dl [10:7-10:12];loadtime;)_",iter, [&](){return rel_Store_fe2fea7187103d89->size();});
if (performIO) {
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","source,base,field"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Store.csv"},{"name","Store"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 3, \"params\": [\"source\", \"base\", \"field\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 3, \"types\": [\"i:number\", \"i:number\", \"i:number\"]}}"}});
if (!inputDirectory.empty()) {directiveMap["fact-dir"] = inputDirectory;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Store_fe2fea7187103d89);
} catch (std::exception& e) {std::cerr << "Error loading Store data: " << e.what() << '\n';
exit(1);
}
}
}
ProfileEventSingleton::instance().makeQuantityEvent( R"(@n-nonrecursive-relation;Store;pointsto.dl [10:7-10:12];)",rel_Store_fe2fea7187103d89->size(),iter);}

} // namespace  souffle

namespace  souffle {
using namespace souffle;
class Sf_pointsto_souffle: public SouffleProgram {
public:
 Sf_pointsto_souffle(std::string pf = "profile.log");
 ~Sf_pointsto_souffle();
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
std::string profiling_fname;
private:
void runFunction(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg);
void dumpFreqs();
SymbolTableImpl symTable;
SpecializedRecordTable<0> recordTable;
ConcurrentCache<std::string,std::regex> regexCache;
std::size_t freqs[154];
std::size_t reads[7];
Own<t_btree_iii__0_2_1__101__111::Type> rel_Load_410733f1f0b09d0c;
souffle::RelationWrapper<t_btree_iii__0_2_1__101__111::Type> wrapper_rel_Load_410733f1f0b09d0c;
Own<t_btree_ii__0_1__11::Type> rel_PrimitiveAssign_a588bc61ab275f32;
souffle::RelationWrapper<t_btree_ii__0_1__11::Type> wrapper_rel_PrimitiveAssign_a588bc61ab275f32;
Own<t_btree_iii__0_1_2__111::Type> rel_Store_fe2fea7187103d89;
souffle::RelationWrapper<t_btree_iii__0_1_2__111::Type> wrapper_rel_Store_fe2fea7187103d89;
Own<t_btree_ii__0_1__11::Type> rel_AssignAlloc_b325dcfc921b51d2;
souffle::RelationWrapper<t_btree_ii__0_1__11::Type> wrapper_rel_AssignAlloc_b325dcfc921b51d2;
Own<t_btree_ii__0_1__11::Type> rel_Alias_22e56a91218d2f0d;
souffle::RelationWrapper<t_btree_ii__0_1__11::Type> wrapper_rel_Alias_22e56a91218d2f0d;
Own<t_btree_ii__0_1__11__10::Type> rel_delta_Alias_8f4123873f20c8cf;
Own<t_btree_ii__0_1__11__10::Type> rel_new_Alias_4e965446bd3cabe9;
Own<t_btree_ii__0_1__11::Type> rel_Assign_fb9d653572c1dfb9;
souffle::RelationWrapper<t_btree_ii__0_1__11::Type> wrapper_rel_Assign_fb9d653572c1dfb9;
Own<t_btree_ii__0_1__11::Type> rel_delta_Assign_18d3b6e18cfd0f97;
Own<t_btree_ii__0_1__11::Type> rel_new_Assign_8d9a4451a73a497b;
Own<t_btree_ii__1_0__0__11__10__01::Type> rel_VarPointsTo_c1a9f897b9f324f0;
souffle::RelationWrapper<t_btree_ii__1_0__0__11__10__01::Type> wrapper_rel_VarPointsTo_c1a9f897b9f324f0;
Own<t_btree_ii__1_0__0__11__10__01::Type> rel_delta_VarPointsTo_16577dc30fb04e76;
Own<t_btree_ii__1_0__0__11__10__01::Type> rel_new_VarPointsTo_5ea2db765d05791c;
Stratum_Alias_0d78fab14e1b06fc stratum_Alias_f3647b52a0dd5327;
Stratum_AssignAlloc_6559eedfd36944f8 stratum_AssignAlloc_a875b0946602e919;
Stratum_Load_5eb95f150d0bf803 stratum_Load_40680d0dd37de710;
Stratum_PrimitiveAssign_d5bded1efa0ba9ae stratum_PrimitiveAssign_758dbe6a40abbd88;
Stratum_Store_64290d23918eb1da stratum_Store_d1a63f4ddc2ea2a5;
std::string inputDirectory;
std::string outputDirectory;
SignalHandler* signalHandler{SignalHandler::instance()};
std::atomic<RamDomain> ctr{};
std::atomic<std::size_t> iter{};
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
 Sf_pointsto_souffle::Sf_pointsto_souffle(std::string pf):
profiling_fname(std::move(pf)),
symTable(),
recordTable(),
regexCache(),
freqs(),
reads(),
rel_Load_410733f1f0b09d0c(mk<t_btree_iii__0_2_1__101__111::Type>()),
wrapper_rel_Load_410733f1f0b09d0c(0, *rel_Load_410733f1f0b09d0c, *this, "Load", std::array<const char *,3>{{"i:number","i:number","i:number"}}, std::array<const char *,3>{{"base","dest","field"}}, 0),
rel_PrimitiveAssign_a588bc61ab275f32(mk<t_btree_ii__0_1__11::Type>()),
wrapper_rel_PrimitiveAssign_a588bc61ab275f32(1, *rel_PrimitiveAssign_a588bc61ab275f32, *this, "PrimitiveAssign", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"source","dest"}}, 0),
rel_Store_fe2fea7187103d89(mk<t_btree_iii__0_1_2__111::Type>()),
wrapper_rel_Store_fe2fea7187103d89(2, *rel_Store_fe2fea7187103d89, *this, "Store", std::array<const char *,3>{{"i:number","i:number","i:number"}}, std::array<const char *,3>{{"source","base","field"}}, 0),
rel_AssignAlloc_b325dcfc921b51d2(mk<t_btree_ii__0_1__11::Type>()),
wrapper_rel_AssignAlloc_b325dcfc921b51d2(3, *rel_AssignAlloc_b325dcfc921b51d2, *this, "AssignAlloc", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"var","heap"}}, 0),
rel_Alias_22e56a91218d2f0d(mk<t_btree_ii__0_1__11::Type>()),
wrapper_rel_Alias_22e56a91218d2f0d(4, *rel_Alias_22e56a91218d2f0d, *this, "Alias", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"x","y"}}, 0),
rel_delta_Alias_8f4123873f20c8cf(mk<t_btree_ii__0_1__11__10::Type>()),
rel_new_Alias_4e965446bd3cabe9(mk<t_btree_ii__0_1__11__10::Type>()),
rel_Assign_fb9d653572c1dfb9(mk<t_btree_ii__0_1__11::Type>()),
wrapper_rel_Assign_fb9d653572c1dfb9(5, *rel_Assign_fb9d653572c1dfb9, *this, "Assign", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"source","destination"}}, 0),
rel_delta_Assign_18d3b6e18cfd0f97(mk<t_btree_ii__0_1__11::Type>()),
rel_new_Assign_8d9a4451a73a497b(mk<t_btree_ii__0_1__11::Type>()),
rel_VarPointsTo_c1a9f897b9f324f0(mk<t_btree_ii__1_0__0__11__10__01::Type>()),
wrapper_rel_VarPointsTo_c1a9f897b9f324f0(6, *rel_VarPointsTo_c1a9f897b9f324f0, *this, "VarPointsTo", std::array<const char *,2>{{"i:number","i:number"}}, std::array<const char *,2>{{"var","heap"}}, 0),
rel_delta_VarPointsTo_16577dc30fb04e76(mk<t_btree_ii__1_0__0__11__10__01::Type>()),
rel_new_VarPointsTo_5ea2db765d05791c(mk<t_btree_ii__1_0__0__11__10__01::Type>()),
stratum_Alias_f3647b52a0dd5327(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_delta_Alias_8f4123873f20c8cf,*rel_delta_Assign_18d3b6e18cfd0f97,*rel_delta_VarPointsTo_16577dc30fb04e76,*rel_new_Alias_4e965446bd3cabe9,*rel_new_Assign_8d9a4451a73a497b,*rel_new_VarPointsTo_5ea2db765d05791c,*rel_Alias_22e56a91218d2f0d,*rel_Assign_fb9d653572c1dfb9,*rel_AssignAlloc_b325dcfc921b51d2,*rel_Load_410733f1f0b09d0c,*rel_PrimitiveAssign_a588bc61ab275f32,*rel_Store_fe2fea7187103d89,*rel_VarPointsTo_c1a9f897b9f324f0),
stratum_AssignAlloc_a875b0946602e919(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_AssignAlloc_b325dcfc921b51d2),
stratum_Load_40680d0dd37de710(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_Load_410733f1f0b09d0c),
stratum_PrimitiveAssign_758dbe6a40abbd88(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_PrimitiveAssign_a588bc61ab275f32),
stratum_Store_d1a63f4ddc2ea2a5(symTable,recordTable,regexCache,pruneImdtRels,performIO,signalHandler,iter,ctr,inputDirectory,outputDirectory,*rel_Store_fe2fea7187103d89){
addRelation("Load", wrapper_rel_Load_410733f1f0b09d0c, true, false);
addRelation("PrimitiveAssign", wrapper_rel_PrimitiveAssign_a588bc61ab275f32, true, false);
addRelation("Store", wrapper_rel_Store_fe2fea7187103d89, true, false);
addRelation("AssignAlloc", wrapper_rel_AssignAlloc_b325dcfc921b51d2, true, false);
addRelation("Alias", wrapper_rel_Alias_22e56a91218d2f0d, false, false);
addRelation("Assign", wrapper_rel_Assign_fb9d653572c1dfb9, false, true);
addRelation("VarPointsTo", wrapper_rel_VarPointsTo_c1a9f897b9f324f0, false, false);
ProfileEventSingleton::instance().setOutputFile(profiling_fname);
}

 Sf_pointsto_souffle::~Sf_pointsto_souffle(){
}

void Sf_pointsto_souffle::runFunction(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg){

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
ProfileEventSingleton::instance().startTimer();
ProfileEventSingleton::instance().makeTimeEvent("@time;starttime");
{
Logger logger("@runtime;", 0);
ProfileEventSingleton::instance().makeConfigRecord("relationCount", std::to_string(7));{
	Logger logger(R"_(@runtime;)_",iter);
{
 std::vector<RamDomain> args, ret;
stratum_Load_40680d0dd37de710.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_PrimitiveAssign_758dbe6a40abbd88.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_Store_d1a63f4ddc2ea2a5.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_AssignAlloc_a875b0946602e919.run(args, ret);
}
{
 std::vector<RamDomain> args, ret;
stratum_Alias_f3647b52a0dd5327.run(args, ret);
}
}
}
ProfileEventSingleton::instance().stopTimer();
dumpFreqs();

// -- relation hint statistics --
signalHandler->reset();
}

void Sf_pointsto_souffle::run(){
runFunction("", "", false, false);
}

void Sf_pointsto_souffle::runAll(std::string inputDirectoryArg,std::string outputDirectoryArg,bool performIOArg,bool pruneImdtRelsArg){
runFunction(inputDirectoryArg, outputDirectoryArg, performIOArg, pruneImdtRelsArg);
}

void Sf_pointsto_souffle::printAll([[maybe_unused]] std::string outputDirectoryArg){
try {std::map<std::string, std::string> directiveMap({{"IO","stdoutprintsize"},{"attributeNames","source\tdestination"},{"auxArity","0"},{"name","Assign"},{"operation","printsize"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"source\", \"destination\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!outputDirectoryArg.empty()) {directiveMap["output-dir"] = outputDirectoryArg;}
IOSystem::getInstance().getWriter(directiveMap, symTable, recordTable)->writeAll(*rel_Assign_fb9d653572c1dfb9);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

void Sf_pointsto_souffle::loadAll([[maybe_unused]] std::string inputDirectoryArg){
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","base,dest,field"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Load.csv"},{"name","Load"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 3, \"params\": [\"base\", \"dest\", \"field\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 3, \"types\": [\"i:number\", \"i:number\", \"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Load_410733f1f0b09d0c);
} catch (std::exception& e) {std::cerr << "Error loading Load data: " << e.what() << '\n';
exit(1);
}
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","source,dest"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","PrimitiveAssign.csv"},{"name","PrimitiveAssign"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"source\", \"dest\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_PrimitiveAssign_a588bc61ab275f32);
} catch (std::exception& e) {std::cerr << "Error loading PrimitiveAssign data: " << e.what() << '\n';
exit(1);
}
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","var,heap"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","AssignAlloc.csv"},{"name","AssignAlloc"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 2, \"params\": [\"var\", \"heap\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 2, \"types\": [\"i:number\", \"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_AssignAlloc_b325dcfc921b51d2);
} catch (std::exception& e) {std::cerr << "Error loading AssignAlloc data: " << e.what() << '\n';
exit(1);
}
try {std::map<std::string, std::string> directiveMap({{"IO","file"},{"attributeNames","source,base,field"},{"auxArity","0"},{"delimiter",","},{"fact-dir","."},{"filename","Store.csv"},{"name","Store"},{"operation","input"},{"params","{\"records\": {}, \"relation\": {\"arity\": 3, \"params\": [\"source\", \"base\", \"field\"]}}"},{"types","{\"ADTs\": {}, \"records\": {}, \"relation\": {\"arity\": 3, \"types\": [\"i:number\", \"i:number\", \"i:number\"]}}"}});
if (!inputDirectoryArg.empty()) {directiveMap["fact-dir"] = inputDirectoryArg;}
IOSystem::getInstance().getReader(directiveMap, symTable, recordTable)->readAll(*rel_Store_fe2fea7187103d89);
} catch (std::exception& e) {std::cerr << "Error loading Store data: " << e.what() << '\n';
exit(1);
}
}

void Sf_pointsto_souffle::dumpInputs(){
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "Load";
rwOperation["types"] = "{\"relation\": {\"arity\": 3, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_Load_410733f1f0b09d0c);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "PrimitiveAssign";
rwOperation["types"] = "{\"relation\": {\"arity\": 2, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_PrimitiveAssign_a588bc61ab275f32);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "AssignAlloc";
rwOperation["types"] = "{\"relation\": {\"arity\": 2, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_AssignAlloc_b325dcfc921b51d2);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "Store";
rwOperation["types"] = "{\"relation\": {\"arity\": 3, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_Store_fe2fea7187103d89);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

void Sf_pointsto_souffle::dumpOutputs(){
try {std::map<std::string, std::string> rwOperation;
rwOperation["IO"] = "stdout";
rwOperation["name"] = "Assign";
rwOperation["types"] = "{\"relation\": {\"arity\": 2, \"auxArity\": 0, \"types\": [\"i:number\", \"i:number\"]}}";
IOSystem::getInstance().getWriter(rwOperation, symTable, recordTable)->writeAll(*rel_Assign_fb9d653572c1dfb9);
} catch (std::exception& e) {std::cerr << e.what();exit(1);}
}

SymbolTable& Sf_pointsto_souffle::getSymbolTable(){
return symTable;
}

RecordTable& Sf_pointsto_souffle::getRecordTable(){
return recordTable;
}

void Sf_pointsto_souffle::setNumThreads(std::size_t numThreadsValue){
SouffleProgram::setNumThreads(numThreadsValue);
symTable.setNumLanes(getNumThreads());
recordTable.setNumLanes(getNumThreads());
regexCache.setNumLanes(getNumThreads());
}

void Sf_pointsto_souffle::executeSubroutine(std::string name,const std::vector<RamDomain>& args,std::vector<RamDomain>& ret){
if (name == "Alias") {
stratum_Alias_f3647b52a0dd5327.run(args, ret);
return;}
if (name == "AssignAlloc") {
stratum_AssignAlloc_a875b0946602e919.run(args, ret);
return;}
if (name == "Load") {
stratum_Load_40680d0dd37de710.run(args, ret);
return;}
if (name == "PrimitiveAssign") {
stratum_PrimitiveAssign_758dbe6a40abbd88.run(args, ret);
return;}
if (name == "Store") {
stratum_Store_d1a63f4ddc2ea2a5.run(args, ret);
return;}
fatal(("unknown subroutine " + name).c_str());
}

void Sf_pointsto_souffle::dumpFreqs(){
}

} // namespace  souffle
namespace souffle {
SouffleProgram *newInstance_pointsto_souffle(){return new  souffle::Sf_pointsto_souffle;}
SymbolTable *getST_pointsto_souffle(SouffleProgram *p){return &reinterpret_cast<souffle::Sf_pointsto_souffle*>(p)->getSymbolTable();}
} // namespace souffle

#ifndef __EMBEDDED_SOUFFLE__
#include "souffle/CompiledOptions.h"
int main(int argc, char** argv)
{
try{
souffle::CmdOptions opt(R"(program/souffle/pointsto.dl)",
R"()",
R"()",
true,
R"(/dev/null)",
64);
if (!opt.parse(argc,argv)) return 1;
souffle::Sf_pointsto_souffle obj(opt.getProfileName());
#if defined(_OPENMP) 
obj.setNumThreads(opt.getNumJobs());

#endif
souffle::ProfileEventSingleton::instance().makeConfigRecord("", opt.getSourceFileName());
souffle::ProfileEventSingleton::instance().makeConfigRecord("fact-dir", opt.getInputFileDir());
souffle::ProfileEventSingleton::instance().makeConfigRecord("jobs", std::to_string(opt.getNumJobs()));
souffle::ProfileEventSingleton::instance().makeConfigRecord("output-dir", opt.getOutputFileDir());
souffle::ProfileEventSingleton::instance().makeConfigRecord("version", "2.4");
obj.runAll(opt.getInputFileDir(), opt.getOutputFileDir());
return 0;
} catch(std::exception &e) { souffle::SignalHandler::instance()->error(e.what());}
}
#endif

namespace  souffle {
using namespace souffle;
class factory_Sf_pointsto_souffle: souffle::ProgramFactory {
public:
souffle::SouffleProgram* newInstance();
 factory_Sf_pointsto_souffle();
private:
};
} // namespace  souffle
namespace  souffle {
using namespace souffle;
souffle::SouffleProgram* factory_Sf_pointsto_souffle::newInstance(){
return new  souffle::Sf_pointsto_souffle();
}

 factory_Sf_pointsto_souffle::factory_Sf_pointsto_souffle():
souffle::ProgramFactory("pointsto_souffle"){
}

} // namespace  souffle
namespace souffle {

#ifdef __EMBEDDED_SOUFFLE__
extern "C" {
souffle::factory_Sf_pointsto_souffle __factory_Sf_pointsto_souffle_instance;
}
#endif
} // namespace souffle

