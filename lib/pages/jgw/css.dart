String css() {
  return '''
<style>

html, body, .page {
    width: 100%;
    height: 100%;
    margin:0;
    padding:0;
}

.shiyiRoot {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
}

.shiyiWord {
    font-size: 15rem;
    text-align: center;
}

.shiyiContent {
    /* display: none; */
    padding: 0 16px;
    font-size: 1.2rem;
}

.shiyiTitle {
    font-size: 2rem;
    position: relative;
    padding: 0 0.2rem;
}

.shiyiSudic {
    position: absolute;
    right: 0.2rem;
    bottom: 0;
    font-size: 1rem;
    color: rgb(146, 205, 220);
    display: none;
}

.shiyiCoreContent {
    margin-top: 1.5rem;
}

.shiyiCoreClass1 {
    color: darkgray;
    font-style: italic;
}

.shiyiCoreClass2 {
    color: darkgray;
    font-style: italic;
}

.shiyiCoreInfo {
    margin: 1rem 0 2rem 0;
    line-height: 2rem;
}

.shiyiRelationTitle {
    font-size: 1.2rem;
    padding-left: 0.2rem;
}

.shiyiRelationWord {
    font-size: 2rem;
    margin-right: 1rem;
    display: inline-block;
}

.shiyiBushou {
    font-size: 2rem;
    display: inline-block;
}

.shiyiJgwNormalFont {
    font-size: 2.4rem;
}

.shiyiYingyong {
    color:#5cadff;
}

.shiyiTrial {
    position: absolute;
    background-color: rgba(0,0,0,0.9);
    display: flex;
    align-items: center;
    justify-content: center;
    color: red;
    font-size: 96px;
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;
}

.shiyiXiaoziyiwei {
    color:red;
    font-weight:bold;
}


.sw {
    width: calc(100% - 20px);
    background: rgba(0,0,0,.1);
    border-radius: 10px;
    padding: 10px;
    margin-bottom: 20px;
}
.sw .title {
    color: green;
    font-size: 1.1em;
    font-weight: bold;
}

.sw .bottom {
    margin-top: 20px;
    text-align: right;
}


.classTitle {
    font-size: 1.1em;
    margin-top: 1em;
    color: green;
}

.bigFont {
    font-size: 3em;
}

.jianhuazi {
    background: lightcoral;
    border-radius: 10px;
    padding: 10px;
    color: black;
}
</style>
''';
}
