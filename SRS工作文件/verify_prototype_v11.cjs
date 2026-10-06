const {chromium}=require('playwright');
const fs=require('fs'),path=require('path'),assert=require('assert');
const {pathToFileURL}=require('url');
const root=path.resolve(__dirname,'..');
const prototype=path.join(root,'项目交互原型');
const out=path.join(root,'artifacts','prototype-v11','screenshots');
const reportPath=path.join(root,'artifacts','prototype-v11','交互检查结果.json');
(async()=>{
 fs.mkdirSync(out,{recursive:true});
 const browser=await chromium.launch({headless:true,...(process.env.PLAYWRIGHT_EXECUTABLE_PATH?{executablePath:process.env.PLAYWRIGHT_EXECUTABLE_PATH}:{})});
 const page=await browser.newPage({viewport:{width:1366,height:900}}),errors=[],results=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
 const action=async(name)=>page.locator(`[data-action="${name}"]`).filter({visible:true}).first().click();
 const nav=async(id)=>page.locator(`.nav-item[data-go="${id}"]`).click();
 const role=async(value)=>page.locator('#role-switch').selectOption(value);
 const scenario=async(value)=>page.locator('#scenario-switch').selectOption(value);
 const check=async(name,fn)=>{await fn();results.push({name,status:'PASS'})};
 await page.goto(pathToFileURL(path.join(prototype,'index.html')).href);await page.locator('.hero').waitFor();
 await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'01-项目导览.png'),fullPage:true});
 await check('完整业务链：备案→企业提交→市审→省审→统计→模拟回执',async()=>{
  await action('start-journey');await action('journey-next');await action('profile-submit');
  assert.equal(await page.evaluate(()=>S.firms.A.filing),'PENDING');
  await action('journey-next');await action('filing-detail');await action('filing-approve');
  await action('journey-next');await page.locator('#primaryDescription').fill('');await action('report-submit');
  assert((await page.locator('#form-errors').innerText()).includes('主要原因说明'));
  await page.locator('#primaryDescription').fill('示例订单不足导致人数减少');await action('report-submit');
  assert.equal(await page.evaluate(()=>S.reports.A.status),'CITY_PENDING');
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'02-企业提交后.png'),fullPage:true});
  await action('journey-next');await action('review-detail');await action('review-approve');
  assert.equal(await page.evaluate(()=>S.reports.A.status),'PROVINCE_PENDING');
  await action('journey-next');await action('review-detail');await action('review-approve');
  await action('journey-next');assert.deepEqual(await page.evaluate(()=>totals(validReports())),{N:2,B:150,E:140,D:-10,L:20,R:-10/150*100});
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'03-原始统计.png'),fullPage:true});
  await action('journey-next');await action('batch-create');await action('batch-send');await page.waitForFunction(()=>S.batches[0].status==='ACKNOWLEDGED');
  assert.equal(await page.evaluate(()=>S.batches[0].records.reduce((a,r)=>a+r.employedCount,0)),140);
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'04-模拟接收回执.png'),fullPage:true});await action('journey-exit');
 });
 await check('独立修订：保存不生效、生效145、原始140、冻结批次140',async()=>{
  await nav('correction');await action('correction-edit');await action('correction-save');
  assert.equal(await page.evaluate(()=>S.reports.A.revision?.active||false),false);
  await action('correction-activate');await action('correction-activate-confirm');
  await nav('stats');await page.locator('#data-basis').selectOption('CORRECTED');
  assert.equal(await page.evaluate(()=>totals(validReports()).E),145);
  assert.equal(await page.evaluate(()=>S.batches[0].records.reduce((a,r)=>a+r.employedCount,0)),140);
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'05-修订统计.png'),fullPage:true});
  await page.locator('#data-basis').selectOption('ORIGINAL');assert.equal(await page.evaluate(()=>totals(validReports()).E),140);
 });
 await check('省级退回：备注选填、企业重提重新进入市审',async()=>{
  await scenario('daily');await role('enterprise');await nav('report');await action('report-submit');
  await role('city');await nav('review');await action('review-detail');await action('review-approve');
  await role('province');await nav('review');await action('review-detail');await action('review-return');
  assert.equal(await page.evaluate(()=>S.reports.A.status),'PROVINCE_RETURNED');
  await role('enterprise');await nav('report');
  await action('report-submit');assert.equal(await page.evaluate(()=>S.reports.A.status),'CITY_PENDING');
 });
 await check('过期窗口：默认72小时补报、授权到期禁止提交',async()=>{
  await scenario('late');await nav('report');assert(await page.locator('[data-action="report-submit"]').isDisabled());
  await role('province');await nav('supplement');await action('supplement-new');await action('supplement-save');
  assert.equal(await page.evaluate(()=>new Date(S.supplements[0].end.replace(' ','T')+'+08:00')-new Date(S.now.replace(' ','T')+'+08:00')),72*3600000);
  await role('enterprise');await nav('report');assert(!(await page.locator('[data-action="report-submit"]').isDisabled()));
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'06-补报表单.png'),fullPage:true});
  await role('province');await nav('supplement');await action('supplement-expire');
  await role('enterprise');await nav('report');assert(await page.locator('[data-action="report-submit"]').isDisabled());
 });
 await check('交换未知：先查回执、未知批次引用禁删；完成后删除恢复',async()=>{
  await scenario('exchange');await role('province');await nav('exchange');await page.locator('#mock-receipt').selectOption('unknown');
  await action('batch-create');await action('batch-send');await page.waitForFunction(()=>S.batches[0].status==='UNKNOWN');
  await nav('trash');await action('report-delete-preview');assert(await page.locator('[data-action="report-delete-confirm"]').isDisabled());await action('close');
  await nav('exchange');await action('batch-receipt');await nav('trash');await action('report-delete-preview');
  await page.locator('#delete-reason').fill('示例历史数据误提交');await action('report-delete-confirm');await action('report-delete-execute');
  assert(await page.evaluate(()=>S.reports.A.deleted));assert.equal(await page.evaluate(()=>validReports().length),1);
  assert.equal(await page.evaluate(()=>S.batches[0].records.length),2);await action('report-restore');assert.equal(await page.evaluate(()=>validReports().length),2);
 });
 await check('REAL缺配置：明确报错，不退回模拟成功',async()=>{
  await nav('exchange');await page.locator('#exchange-mode').selectOption('REAL');await action('batch-create');await action('batch-send');
  assert((await page.locator('#dialog').innerText()).includes('EXCHANGE_NOT_CONFIGURED'));assert.equal(await page.evaluate(()=>S.batches[0].status),'QUEUED');await action('close');
 });
 await check('部分拒绝：修订后只补发失败项，已接受条目不重发',async()=>{
  await scenario('exchange');await nav('exchange');await page.locator('#mock-receipt').selectOption('partial');
  await action('batch-create');await action('batch-send');await page.waitForFunction(()=>S.batches[0].status==='REJECTED');
  assert.equal(await page.evaluate(()=>S.batches[0].receipt.acceptedCount),1);
  await action('batch-retry');assert((await page.locator('#dialog').innerText()).includes('旧提交'));await action('to-correction');
  await action('correction-edit');await action('correction-save');await action('correction-activate');await action('correction-activate-confirm');
  await nav('exchange');await action('batch-retry');assert.equal(await page.evaluate(()=>S.batches[0].records.length),1);
  assert.equal(await page.evaluate(()=>S.batches[0].records[0].revisionVersion),1);
  await action('batch-send');await page.waitForFunction(()=>S.batches[0].status==='ACKNOWLEDGED');
 });
 await check('连续修订撤销恢复上一有效版本，修订编号不复用',async()=>{
  await nav('correction');await action('correction-edit');await page.locator('#E').fill('88');await action('correction-save');
  await action('correction-activate');await action('correction-activate-confirm');assert.equal(await page.evaluate(()=>S.reports.A.revision.data.E),88);
  await action('correction-revoke');await action('correction-revoke-confirm');assert.equal(await page.evaluate(()=>S.reports.A.revision.data.E),85);
  await action('correction-edit');await action('correction-save');assert.equal(await page.evaluate(()=>S.reports.A.revisionDraft.version),3);
 });
 await check('条件必填星号随人数变化，空分类保存草稿不崩溃',async()=>{
  await scenario('daily');await role('enterprise');await nav('report');await page.locator('#E').fill('100');
  assert(await page.locator('label[for="reductionType"] .required').isHidden());
  await action('report-save');await scenario('onboarding');await nav('profile');await page.locator('#natureParent').selectOption('');
  await action('profile-save');await nav('dashboard');await nav('profile');assert(await page.locator('#natureCode').isVisible());
 });
 await check('页面方向记录：保存、显示，不发送外部消息',async()=>{
  await role('province');await nav('stats');await action('help');await page.locator('#review-note').fill('保持原始与修订口径分离，支持核对数字。');await action('note-save');
  await nav('guide');await action('notes-view');assert((await page.locator('#dialog').innerText()).includes('保持原始与修订口径分离'));await action('close');
 });
 await check('省级默认具备管理和账号导出；13条件查询含未报与停用账号',async()=>{
  await scenario('stats');await role('province');await nav('query');
  assert.equal(await page.locator('.query-grid input,.query-grid select').count(),13);
  assert.equal(await page.locator('#query-count').innerText(),'7');
  assert((await page.locator('#main').innerText()).includes('qy_c'));
  await page.locator('#q-login').fill('qy_c');await action('query-search');assert.equal(await page.locator('#query-count').innerText(),'1');
  await action('export-preview');assert.equal(await page.locator('#export-count').innerText(),'1');await action('close');
  await action('query-clear');await page.locator('#q-state').selectOption('APPROVED');await page.locator('#q-month').fill('2026-09');await action('query-search');assert.equal(await page.locator('#query-count').innerText(),'2');
  await page.locator('#q-quarter').selectOption('2026-Q2');await action('query-search');assert((await page.locator('#form-errors').innerText()).includes('月份'));
  await action('query-clear');await action('query-reports');assert.equal(await page.locator('#query-count').innerText(),'4');
  await page.locator('#q-start').fill('2026-09-01');await page.locator('#q-end').fill('2026-09-30');await action('query-search');assert.equal(await page.locator('#query-count').innerText(),'1');
  await action('query-clear');await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'08-十三条件查询.png'),fullPage:true});
  await nav('users');assert(!(await page.locator('[data-action="export-preview"]').isDisabled()));
 });
 await check('备案按生效月取快照；丙未上报仍入样本；饼图分母随地区改变',async()=>{
  await nav('archives');assert.equal(await page.evaluate(()=>archiveRows().length),3);
  await page.locator('#ar-month').fill('2026-04');await action('archive-search');assert.equal(await page.evaluate(()=>archiveRows().length),0);
  await page.locator('#ar-month').fill('2026-09');await action('archive-search');assert.equal(await page.evaluate(()=>archiveRows().length),3);
  await nav('sample');assert.equal(await page.evaluate(()=>sampleRows().length),3);assert((await page.locator('#main').innerText()).includes('66.67%'));
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'09-备案取样饼图.png'),fullPage:true});
  await page.locator('#s-city').selectOption('YN-C01');await action('sample-search');assert.equal(await page.evaluate(()=>sampleRows().length),2);assert((await page.locator('#main').innerText()).includes('100.00%'));
  await action('sample-clear');await page.locator('#s-mode').selectOption('REPORTED');await action('sample-search');assert((await page.locator('#form-errors').innerText()).includes('月份'));
  await page.locator('#s-month').fill('2026-09');await action('sample-search');assert.equal(await page.evaluate(()=>sampleRows().length),2);
 });
 await check('两期共同与独立样本、三维分组、连续缺月断线一致',async()=>{
  await nav('compare');assert.equal(await page.evaluate(()=>totals(comparisonData().b).N),1);
  await page.locator('#a-dimension').selectOption('industry');await page.locator('#sample-mode').selectOption('independent');await action('compare-apply');assert.equal(await page.evaluate(()=>totals(comparisonData().b).N),2);assert.equal(await page.locator('#a-dimension').inputValue(),'industry');
  for(const dim of ['city','nature','industry']){await page.locator('#a-dimension').selectOption(dim);await action('compare-apply');assert.equal(await page.locator('svg.chart').count(),1)}
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'10-两期多维对比.png'),fullPage:true});
  await nav('trend');assert((await page.locator('#main').innerText()).includes('-10.00%'));assert((await page.locator('#main').innerText()).includes('缺失，不补0'));
  await page.locator('#a-start').fill('2026-09');await page.locator('#a-end').fill('2026-06');await action('trend-apply');assert((await page.locator('#form-errors').innerText()).includes('开始'));
  await page.locator('#a-quarter').selectOption('2026-Q3');await action('trend-apply');assert.equal(await page.locator('#a-start').inputValue(),'2026-07');
 });
 await check('通知本人管理、同级隔离、下级可读、删除留痕',async()=>{
  await nav('notices');assert.equal(await page.locator('.notice').count(),1);
  await page.locator('#province-account').selectOption('u7');assert((await page.locator('.notice').innerText()).includes('数据修订'));
  await action('notice-new');await page.locator('#notice-title').fill('测试通知');await page.locator('#notice-body').fill('纯文本内容 <b>不会解释为标签</b>');await action('notice-save');assert.equal(await page.locator('.notice').count(),2);
  await action('notice-manage');await action('notice-delete');await action('notice-delete-confirm');assert.equal(await page.locator('.notice').count(),2);assert((await page.locator('#main').innerText()).includes('已删除'));
  await action('notice-read');assert.equal(await page.locator('.notice').count(),1);
  await page.locator('#province-account').selectOption('u4');assert.equal(await page.locator('.notice').count(),1);
  await role('enterprise');await nav('notices');assert.equal(await page.locator('.notice').count(),2);
 });
 await check('账号增改、本人提交禁删、角色增改分配删除、调查期新增和修改',async()=>{
  await role('province');await nav('users');await action('user-new');await page.locator('#user-login').fill('qy_extra');await page.locator('#user-firm').selectOption('C');await action('user-save');
  const id=await page.evaluate(()=>S.users.at(-1).id);await page.locator(`[data-action="user-edit"][data-id="${id}"]`).click();await page.locator('#edit-login').fill('qy_extra2');await action('user-edit-save');assert.equal(await page.evaluate(()=>S.users.at(-1).login),'qy_extra2');
  await page.locator('[data-action="user-delete"][data-id="u1"]').click();assert((await page.locator('#dialog').innerText()).includes('禁止删除'));await action('close');
  await nav('roles');await action('role-new');await page.locator('#custom-role-name').fill('企业历史查看');await page.locator('#custom-role-identity').selectOption('企业');await page.locator('[name="custom-permission"][value="history"]').check();await action('role-save');
  const rid=await page.evaluate(()=>S.roleTemplates.at(-1).id);await page.locator(`[data-action="role-edit"][data-id="${rid}"]`).click();await page.locator('#custom-role-name').fill('企业历史阅读');await action('role-save');
  await nav('users');await page.locator(`[data-action="user-role"][data-id="${id}"]`).click();await page.locator('[name="user-role-check"][value="企业"]').uncheck();await page.locator('[name="user-role-check"][value="企业历史阅读"]').check();await action('user-role-save');
  await nav('roles');await page.locator(`[data-action="role-delete"][data-id="${rid}"]`).click();await action('role-delete-confirm');assert.equal(await page.evaluate(()=>S.users.at(-1).roles.length),0);
  await nav('users');await page.locator(`[data-action="user-delete"][data-id="${id}"]`).click();await action('user-delete-confirm');assert(await page.evaluate(()=>S.users.at(-1).deleted));
  await nav('periods');await action('period-new');await action('period-create');assert.equal(await page.evaluate(()=>S.periods.length),2);
  await page.locator('#periodEnd').fill('2026-11-15T00:00');await action('period-save');assert.equal(await page.evaluate(()=>S.periods[1].end),'2026-11-15T00:00');
  await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'11-调查期设置.png'),fullPage:true});
 });
 await check('编码可申请变更；名字和传真校验；次要第三原因独立选填',async()=>{
  await scenario('daily');await role('enterprise');await nav('profile');await action('profile-edit');assert(!(await page.locator('#enterpriseCode').isDisabled()));
  await page.locator('#name').fill('企业123');await page.locator('#fax').fill('无');await action('profile-submit');assert((await page.locator('#form-errors').innerText()).includes('中文英文'));assert((await page.locator('#form-errors').innerText()).includes('传真'));
  await page.locator('#name').fill('示例企业甲');await page.locator('#fax').fill('(0871)12345678');await page.locator('#enterpriseCode').fill('a001');await action('profile-submit');assert.equal(await page.evaluate(()=>S.firms.A.change.data.enterpriseCode),'A001');
  await nav('report');await page.locator('#secondaryReason').selectOption('RC04');await page.locator('#tertiaryDescription').fill('独立说明');await action('report-submit');assert.equal(await page.evaluate(()=>S.reports.A.status),'CITY_PENDING');
  await role('city');await nav('review');await action('review-detail');await action('review-approve');
  await role('province');await nav('correction');await action('correction-edit');await action('correction-save');assert(await page.locator('[data-action="correction-activate"][data-id="A"]').isDisabled());
  await nav('review');await action('review-detail');await action('review-approve');await nav('correction');await page.locator('[data-action="correction-activate"][data-id="A"]').click();await action('correction-activate-confirm');assert(await page.evaluate(()=>S.reports.A.revision.active));
 });
 await check('历史月份筛选、提交快照和市级范围',async()=>{
  await role('enterprise');await nav('history');await page.locator('#h-month').fill('2026-08');await action('history-search');assert.equal(await page.locator('[data-action="query-detail"]').count(),1);await action('query-detail');assert((await page.locator('#dialog').innerText()).includes('90'));assert((await page.locator('#dialog').innerText()).includes('v1'));await action('close');
  await role('city');await nav('history');await action('history-clear');assert(!(await page.locator('#main').innerText()).includes('示例企业乙'));
 });

 await check('全部角色页面可渲染且无控制台错误',async()=>{
  for(const [r,ids] of Object.entries(await page.evaluate(()=>menus))){await role(r);for(const id of ids){await nav(id);assert(await page.locator('#main').isVisible())}}
 });
 await role('enterprise');await nav('guide');await page.setViewportSize({width:390,height:844});
 await page.evaluate(()=>{window.scrollTo(0,0);document.querySelector('#toast').style.display='none'});await page.screenshot({path:path.join(out,'07-窄屏导览.png'),fullPage:true});
 await check('390像素窄屏主体不横向溢出',async()=>assert(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth)));
 assert.deepEqual(errors,[]);results.push({name:'运行时错误检查',status:'PASS',errors});
 fs.writeFileSync(reportPath,JSON.stringify({version:'V1.1',checkedAt:new Date().toISOString(),viewport:'1366×900 / 390×844',results},null,2));
 console.log(JSON.stringify(results,null,2));await browser.close();
})().catch(err=>{console.error(err);process.exit(1)});
