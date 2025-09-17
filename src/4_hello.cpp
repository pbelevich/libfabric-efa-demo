#include <rdma/fabric.h>
#include <rdma/fi_cm.h>
#include <rdma/fi_domain.h>
#include <rdma/fi_endpoint.h>
#include <rdma/fi_errno.h>
#include <rdma/fi_rma.h>

#include <cstdio>
#include <cstdlib>

#define CHECK(stmt)                                                            \
  do {                                                                         \
    if (!(stmt)) {                                                             \
      fprintf(stderr, "%s:%d %s\n", __FILE__, __LINE__, #stmt);                \
      std::exit(1);                                                            \
    }                                                                          \
  } while (0)

#define FI_CHECK(stmt)                                                         \
  do {                                                                         \
    int rc = (stmt);                                                           \
    if (rc) {                                                                  \
      fprintf(stderr, "%s:%d %s failed with %d (%s)\n", __FILE__, __LINE__,    \
              #stmt, rc, fi_strerror(-rc));                                    \
      std::exit(1);                                                            \
    }                                                                          \
  } while (0)

struct fi_info *GetInfo() {
    struct fi_info *hints, *info;
    hints = fi_allocinfo();
    hints->ep_attr->type = FI_EP_RDM;
    hints->fabric_attr->prov_name = strdup("efa");
    FI_CHECK(fi_getinfo(FI_VERSION(2, 0), nullptr, nullptr, 0, hints, &info));
    fi_freeinfo(hints);
    return info;
}

int main() {
    struct fi_info *info = GetInfo();
    for (auto *fi = info; fi; fi = fi->next) {
        printf("domain: %14s", fi->domain_attr->name);
        printf(", nic: %10s", fi->nic->device_attr->name);
        printf(", fabric: %s", fi->fabric_attr->prov_name);
        printf(", link: %.0fGbps", fi->nic->link_attr->speed / 1e9);
        printf("\n");
    }
    return 0;
}
