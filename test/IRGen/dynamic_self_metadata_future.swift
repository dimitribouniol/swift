// RUN: %target-swift-frontend %s -target %module-target-future -emit-ir -parse-as-library | %FileCheck %s -DINT=i%target-ptrsize -DALIGNMENT=%target-alignment


// REQUIRES: OS=macosx || OS=ios || OS=tvos || OS=watchos || OS=linux-gnu
// REQUIRES: CPU=x86_64

// FIXME: Not a SIL test because we can't parse dynamic Self in SIL.
// <rdar://problem/16931299>

// CHECK: [[TYPE:%.+]] = type <{ [8 x i8] }>

@inline(never) func id<T>(_ t: T) -> T {
  return t
}
// CHECK-LABEL: define hidden swiftcc void @"$s28dynamic_self_metadata_future2idyxxlF"

protocol P {
  associatedtype T
}

extension P {
  func f() {}
}

struct G<T> : P {
  var t: T
}

class C {
  class func fromMetatype() -> Self? { return nil }
  // CHECK-LABEL: define hidden swiftcc i64 @"$s28dynamic_self_metadata_future1CC12fromMetatypeACXDSgyFZ"(%swift.type* swiftself %0)
  // CHECK: ret i64 0

  func fromInstance() -> Self? { return nil }
  // CHECK-LABEL: define hidden swiftcc i64 @"$s28dynamic_self_metadata_future1CC12fromInstanceACXDSgyF"(%T28dynamic_self_metadata_future1CC* swiftself %0)
  // CHECK: ret i64 0

  func dynamicSelfArgument() -> Self? {
    return id(nil)
  }
  // CHECK-LABEL: define hidden swiftcc i64 @"$s28dynamic_self_metadata_future1CC0A12SelfArgumentACXDSgyF"(%T28dynamic_self_metadata_future1CC* swiftself %0)
  // CHECK: [[GEP1:%.+]] = getelementptr {{.*}} %0
  // CHECK: [[TYPE1:%.+]] = load {{.*}} [[GEP1]]
  // CHECK: [[T0:%.+]] = call swiftcc %swift.metadata_response @"$sSqMa"(i64 0, %swift.type* [[TYPE1]])
  // CHECK: [[TYPE2:%.+]] = extractvalue %swift.metadata_response [[T0]], 0
  // CHECK: call swiftcc void @"$s28dynamic_self_metadata_future2idyxxlF"({{.*}}, %swift.type* [[TYPE2]])

  func dynamicSelfConformingType() -> Self? {
    _ = G(t: self).f()
    return nil
  }
  // CHECK-LABEL: define hidden swiftcc i64 @"$s28dynamic_self_metadata_future1CC0A18SelfConformingTypeACXDSgyF"(%T28dynamic_self_metadata_future1CC* swiftself %0)
  // CHECK: [[SELF_GEP:%.+]] = getelementptr {{.*}} %0
  // CHECK: [[SELF_TYPE:%.+]] = load {{.*}} [[SELF_GEP]]
  // CHECK: call i8** @swift_getWitnessTable(
  // CHECK-SAME:   %swift.protocol_conformance_descriptor* bitcast (
  // CHECK-SAME:     {{.*}} @"$s28dynamic_self_metadata_future1GVyxGAA1PAAMc" 
  // CHECK-SAME:     to %swift.protocol_conformance_descriptor*
  // CHECK-SAME:   ), 
  // CHECK-SAME:   %swift.type* getelementptr inbounds (
  // CHECK-SAME:     %swift.full_type, 
  // CHECK-SAME:     %swift.full_type* bitcast (
  // CHECK-SAME:       <{ 
  // CHECK-SAME:         i8**, 
  // CHECK-SAME:         [[INT]], 
  // CHECK-SAME:         %swift.type_descriptor*, 
  // CHECK-SAME:         %swift.type*, 
  // CHECK-SAME:         i32, 
  // CHECK-SAME:         {{(\[4 x i8\])?}}, 
  // CHECK-SAME:         i64 
  // CHECK-SAME:       }>* @"$s28dynamic_self_metadata_future1GVyAA1CCXDGMf" 
  // CHECK-SAME:       to %swift.full_type*
  // CHECK-SAME:     ), 
  // CHECK-SAME:     i32 0, 
  // CHECK-SAME:     i32 1
  // CHECK-SAME:   ), 
  // CHECK-SAME:   i8*** undef
  // CHECK-SAME: )
}
