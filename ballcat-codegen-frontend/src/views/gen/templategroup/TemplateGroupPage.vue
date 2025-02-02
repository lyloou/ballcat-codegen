<template>
  <div>
    <a-card v-show="tableShow" :bordered="false">
      <!-- 查询条件 -->
      <div class="table-page-search-wrapper">
        <a-form layout="inline">
          <a-row :gutter="48">
            <a-col :md="8" :sm="24">
              <a-form-item label="ID">
                <a-input v-model="queryParam.id" placeholder="" />
              </a-form-item>
            </a-col>

            <!-- <template v-if="advanced">
            </template>-->
            <a-col :md="(!advanced && 8) || 24" :sm="24">
              <span
                class="table-page-search-submitButtons"
                :style="(advanced && { float: 'right', overflow: 'hidden' }) || {}"
              >
                <a-button type="primary" @click="reloadTable">查询</a-button>
                <a-button style="margin-left: 8px" @click="resetSearchForm">重置</a-button>
                <!--<a @click="toggleAdvanced" style="margin-left: 8px">
                  {{ advanced ? '收起' : '展开' }}
                  <a-icon :type="advanced ? 'up' : 'down'"/>
                </a>-->
              </span>
            </a-col>
          </a-row>
        </a-form>
      </div>

      <!-- 操作按钮区域 -->
      <div class="table-operator">
        <a-button type="primary" icon="plus" @click="handleAdd()">新建</a-button>
      </div>

      <!--数据表格区域-->
      <div class="table-wrapper">
        <a-table
          ref="table"
          size="middle"
          :row-key="rowKey"
          :columns="columns"
          :data-source="dataSource"
          :pagination="pagination"
          :loading="loading"
          @change="handleTableChange"
        >
          <template #template-action-slot="text, record">
            <a @click="editEntry(record, '编辑模板组 - ' + record.name)">模板编辑</a>
            <a-divider type="vertical" />
            <a @click="editProperties(record)">属性配置</a>
          </template>
          <template #action-slot="text, record">
            <a @click="handleEdit(record)">编辑</a>
            <a-divider type="vertical" />
            <a @click="handleCopy(record)">复制</a>
            <a-divider type="vertical" />
            <a-popconfirm title="确认要删除吗？" @confirm="() => handleDel(record)">
              <a href="javascript:;">删除</a>
            </a-popconfirm>
          </template>
        </a-table>
      </div>
    </a-card>

    <!--表单页面-->
    <a-card
      v-show="!tableShow"
      size="small"
      :body-style="{ padding: '0px' }"
    >
      <slot slot="title">
        <div style="position:relative;height:32px;line-height:32px;padding:0 1%">
          {{ cardTitle }}
          <div style="position:absolute;right:1%;top:0"><a-button @click="backToPage(false)">返回上级</a-button></div>
        </div>
      </slot>
      <form-page ref="formPage" @back-to-page="backToPage" />
    </a-card>

    <!--字典项-->
    <template-property-page-modal ref="propertyPageModal" />

    <!--模板组表单弹窗-->
    <template-group-form-modal ref="formModal" @reload-page-table="reloadTable" />
  </div>
</template>

<script>
import { getPage, delObj } from '@/api/gen/templategroup'
import FormPage from './TemplateEntryForm'
import TemplatePropertyPageModal from './TemplatePropertyPageModal'
import { TablePageMixin } from '@/mixins'
import TemplateGroupFormModal from './TemplateGroupFormModal'

export default {
  name: 'TemplateGroupPage',
  components: { TemplateGroupFormModal, FormPage, TemplatePropertyPageModal },
  mixins: [TablePageMixin],
  data() {
    return {
      getPage: getPage,
      delObj: delObj,

      columns: [
        {
          title: '#',
          dataIndex: 'id'
        },
        {
          title: '名称',
          dataIndex: 'name'
        },
        {
          title: '备注信息',
          dataIndex: 'remarks'
        },
        {
          title: '创建时间',
          dataIndex: 'createTime',
          width: '150px',
          sorter: true
        },
        {
          title: '模板组操作',
          dataIndex: 'templateAction',
          width: '150px',
          scopedSlots: { customRender: 'action-slot' }
        },
        {
          title: '模板操作',
          dataIndex: 'action',
          width: '150px',
          scopedSlots: { customRender: 'template-action-slot' }
        }
      ],

      cardTitle: ''
    }
  },
  methods: {
    handleAdd() {
      this.$refs.formModal.add({ title: '新建模板组' })
    },
    handleEdit(record) {
      this.$refs.formModal.update(record, { title: '编辑模板组' })
    },
    handleCopy(record) {
      this.$refs.formModal.copy(record, { title: '复制模板组' })
    },
    editEntry(record, title) {
      this.switchPage()
      this.$refs.formPage.show(record.id, title)
    },
    editProperties(record) {
      this.$refs.propertyPageModal.show(record)
    }
  }
}
</script>
